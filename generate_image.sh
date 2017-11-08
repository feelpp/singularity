#!/usr/bin/env bash
#
# This script generate singularity bootstrap per docker images
# Usage: ./generate_bootstrap.sh <image:branch>
#

source include_path.sh

if [ ! -f "${BOOTSTRAPDIR}/${BOOTSTRAPFILE}" ]; then
    echo "Bootstrap: ${BOOTSTRAPDIR}/${BOOTSTRAPFILE} not found!"
    echo "You should run './generate_bootstrap.sh ${BASEIMAGETAG}' first!"
    exit 1
fi

# MUST BE SUDO HERE! (--notest to not run test, --section to rebuild only a %section ).
sudo -E ${SINGULARITY_BIN} -vvv build --force --notest "${IMAGEDIR}/${SINGULARITYIMAGE}" "${BOOTSTRAPDIR}/${BOOTSTRAPFILE}"
