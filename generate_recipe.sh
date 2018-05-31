#!/usr/bin/env bash
#
# This script generate singularity recipe per Feel++ docker images
# Usage: ./generate_recipe.sh <image:branch>
#

source include.sh

echo "Using docker image: ${BASE}/${IMG}:${TAG}"
mkdir -p "${SIMG_RECIPE_DIR}"
echo "Generate recipe file: ${SIMG_RECIPE_DIR}/${SIMG_RECIPE}"
cat ./recipe | sed "s/From:.*$/From: ${BASE}\/${IMG}:${TAG}/g" > "${SIMG_RECIPE_DIR}/${SIMG_RECIPE}"
cp -r ./singularity.d ${SIMG_RECIPE_DIR}/
