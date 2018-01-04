#!/usr/bin/env bash
#
# This script generate singularity bootstrap per docker images
# Usage: ./generate_image.sh <image:branch>
#

source include.sh

if [ ! -f "${SIMG_RECIPE_DIR}/${SIMG_RECIPE}" ]; then
    echo "Recipe: ${SIMG_RECIPE_DIR}/${SIMG_RECIPE} not found!"
    echo "You should run './generate_recipe.sh ${BASE_IMG_TAG}' first!"
    exit 1
fi

# MUST BE SUDO HERE! (--notest to not run test, --section to rebuild only a %section ).
sudo -E ${SINGULARITY_BIN} -vvv build --force --notest "${SIMG_DIR}/${SIMG}" "${SIMG_RECIPE_DIR}/${SIMG_RECIPE}"
