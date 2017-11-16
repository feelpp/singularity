#!/usr/bin/env bash
#
# This script generate singularity bootstrap per Feel++ docker images
# Usage: ./generate_bootstrap.sh <image:branch>
#

if [ $# -eq 0 ]; then
    echo "Usage: $0 <base/image:tag>"
    exit 0;
fi

SINGULARITY_BIN=`which singularity`

if [[ "${SINGULARITY_BIN}" == "" ]]; then
    echo "singularity binary not found!"
    exit 1
fi

SINGULARITY_MAJOR_VERSION=`${SINGULARITY_BIN} --version | sed 's/\([0-9]*\)[.]*[0-9]*[.]*[0-9]*.*/\1/'`
SINGULARITY_MINOR_VERSION=`${SINGULARITY_BIN} --version | sed 's/[0-9]*[.]*\([0-9]*\)[.]*[0-9]*.*/\1/'`
SINGULARITY_PATCH_VERSION=`${SINGULARITY_BIN} --version | sed 's/[0-9]*[.]*[0-9]*[.]*\([0-9]*\).*/\1/'`
DOCKERIMAGE=$1
BASEIMAGE=`echo "${DOCKERIMAGE}" | sed 's/:.*//'`
BASE=`echo "${BASEIMAGE}" | sed 's/\/.*//'`
IMAGE=`echo "${BASEIMAGE}" | sed 's/.*\///'`
TAG_FROM_DOCKER_IMAGE=`echo "${DOCKERIMAGE}" | sed "s/.*://"`
TAG=${FEELPP_DOCKER_TAG:-${TAG_FROM_DOCKER_IMAGE}}
if [ ! -n "$TAG" ] || [ "$TAG" ==  "$DOCKERIMAGE" ]; then
    TAG=latest
fi
BASEIMAGETAG=${BASE}/${IMAGE}:${TAG}
ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
BOOTSTRAPDIR=${ROOTDIR}/images/${BASE}/${IMAGE}/${TAG}
BOOTSTRAPFILE=Singularity.${IMAGE}-${TAG}
IMAGEDIR=$BOOTSTRAPDIR
FTPDIR=""
if [ ! -z "${FTP_SINGULARITY_IMAGES_DIR}" ]; then
    FTPDIR=${FTP_SINGULARITY_IMAGES_DIR}
else
    echo "singularity ftp directory not set! (export FTP_SINGULARITY_IMAGES_DIR=/path/to/ftp)"
fi

SINGULARITYIMAGE=singularity_${BASE}_${IMAGE}-${TAG}.img

# DEBUG
#echo $BASEIMAGETAG
#echo "singularity version: ${SINGULARITY_MAJOR_VERSION}.${SINGULARITY_MINOR_VERSION}.${SINGULARITY_PATCH_VERSION}"
