#!/usr/bin/env bash
#
# This script generate singularity bootstrap per Feel++ docker images
# Usage: ./generate_bootstrap.sh <image:branch>
#

set -e

usage(){
	echo "Usage: $0 [ <options> ] <base/image:tag>"
	echo ""
	echo "Options:"
	echo ""
	echo "-g <girder_id> girder folder id where to push images (./push_image.sh)"
	echo "-h             print help"
	echo ""
	exit 1
}

if [ "$#" -lt 1 ]; then
    usage
fi

while getopts ":g:" option ; do
	case $option in
		h ) usage ;;
		g ) GIRDER_FOLDER_PARENT_ID=$OPTARG;;
		? ) usage ;;
	esac
done

# Default.
#: ${GIRDER_FOLDER_PARENT_ID:=""}

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
SINGULARITY_BIN=`which singularity`

if [[ "${SINGULARITY_BIN}" == "" ]]; then
    echo "singularity binary not found!"
    exit 1
fi

SINGULARITY_MAJOR_VERSION=`${SINGULARITY_BIN} --version | sed 's/\([0-9]*\)[.]*[0-9]*[.]*[0-9]*.*/\1/'`
SINGULARITY_MINOR_VERSION=`${SINGULARITY_BIN} --version | sed 's/[0-9]*[.]*\([0-9]*\)[.]*[0-9]*.*/\1/'`
SINGULARITY_PATCH_VERSION=`${SINGULARITY_BIN} --version | sed 's/[0-9]*[.]*[0-9]*[.]*\([0-9]*\).*/\1/'`

# DockerHub image.
BASE_IMG_TAG="${@: -1}"
BASE_IMG=`echo "${BASE_IMG_TAG}" | sed 's/:.*//'`
BASE=`echo "${BASE_IMG}" | sed 's/\/.*//'`
IMG=`echo "${BASE_IMG}" | sed 's/.*\///'`
TAG=`echo "${BASE_IMG_TAG}" | sed "s/.*://"`
if [ ! -n "$TAG" ] || [ "${TAG}" == "${IMG}" ]; then
    TAG=latest
fi
# Transform the generic tag latest into the long version.
# Regex for the desired tag name
# for example: develop-v0.104.0-alpha.3-ubuntu-16.04
# Note: we retrieve the list of tag for the image, compare those which have the
# same digest than latest, and keep the one which has the desire regex expression.
# If the tag expr is not found, we keep the current latest tag.
dhub_token()
{
    DHUB_TOKEN=`curl -u ${DOCKER_LOGIN}:${DOCKER_PASSWORD} -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${BASE}/${IMG}:pull" | jq -r .token`
    export DHUB_TOKEN
}
dhub_pull()
{
    docker pull "$1" 
}
dhub_tag_list()
{
    DHUB_TAG_LIST=`curl -s -H "Authorization: Bearer ${DHUB_TOKEN}" https://index.docker.io/v2/${BASE}/${IMG}/tags/list | jq -rc ".tags[]"`
    export DHUB_TAG_LIST
}

# dhub_tag_digest <tag>
dhub_tag_digest()
{
    DHUB_TAG_DIGEST=`curl -s -vvv -X GET \
        -H "Authorization: Bearer ${DHUB_TOKEN}" \
        -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
        https://index.docker.io/v2/${BASE}/${IMG}/manifests/$1 2>&1 \
        | grep "Docker-Content-Digest" \
        | sed -E "s/.*Docker-Content-Digest: *(.*)/\1/"`
    export DHUB_TAG_DIGEST
}

TAGEXPR=".*-v[0-9]*(.[0-9]*)*-.*(.[0-9]*)*-.*-[0-9]*(.[0-9]*)*.*"
if [ "${BASE}" == "feelpp" ]\
    && [ "${TAG}" == "latest" ]\
   || [ "${TAG}" == "master" ]\
   || [ "${TAG}" == "develop" ]; then
    dhub_token
    dhub_tag_list
    dhub_tag_digest ${TAG}
    
    LATEST_DIGEST=${DHUB_TAG_DIGEST}
    echo "Checking all tag related to ${TAG}..."
    for tag in $DHUB_TAG_LIST; do
        dhub_tag_digest ${tag}
        if [ "${LATEST_DIGEST}" == "${DHUB_TAG_DIGEST}" ]; then
            echo "${tag}: ${DHUB_TAG_DIGEST}"
            # [[ "${tag}" =~ ^${TAGEXPR}$ ]] && TAG=${tag}
            TAG=${tag}
            break
        fi
    done
fi
BASE_IMG_TAG=${BASE}/${IMG}:${TAG}

# make sure the image is there
dhub_pull "${BASE}/${IMG}:${TAG}"

# Singularity image.
SIMG_RECIPE_DIR=${ROOT_DIR}/images/${BASE}/${IMG}/${TAG}
SIMG_RECIPE=Singularity.${IMG}-${TAG}
SIMG_DIR=${SIMG_RECIPE_DIR}
SIMG=${BASE}_${IMG}-${TAG}.simg

SIMG_MSO4SC_REGISTRY_NAME="${COLLECTION:-mso4sc}/${IMG}"
SIMG_MSO4SC_REGISTRY_TAG=v`echo ${TAG} | sed "s/.*v[0-9]*\.\([0-9]*\)\..*/\1/g"`
