#!/usr/bin/env bash
#
# This script generate singularity bootstrap per Feel++ docker images
# Usage: ./generate_bootstrap.sh <image:branch>
#

source include_path.sh

echo "Using docker image: ${DOCKERIMAGE}"
mkdir -p ${BOOTSTRAPDIR}
echo "Generate bootstrap file: ${BOOTSTRAPDIR}/${BOOTSTRAPFILE}"
cat ./bootstrap.def | sed "s/From:.*$/From: ${BASE}\/${IMAGE}:${TAG}/g" > "${BOOTSTRAPDIR}/${BOOTSTRAPFILE}"
cp -r ./singularity.d ${BOOTSTRAPDIR}/
