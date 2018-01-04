#!/usr/bin/env bash
#
# This script generate singularity bootstrap per Feel++ docker images
# Usage: ./generate_bootstrap.sh <image:branch>
#

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

BASE_IMG_TAG=${BASE}/${IMG}:${TAG}

# Singularity image.
SIMG_RECIPE_DIR=${ROOT_DIR}/images/${BASE}/${IMG}/${TAG}
SIMG_RECIPE=Singularity.${IMG}-${TAG}
SIMG_DIR=${SIMG_RECIPE_DIR}
SIMG=${BASE}_${IMG}-${TAG}.simg
