#!/bin/bash
# This script place singularity images *.img to a ftp folder on the same
# machine.
#
# The environment variable FTP_SINGULARITY_IMAGES_DIR has to be set system wide!
#

set -euo pipefail

source include_path.sh

# Copy (overide) generated images in the repository.
echo "-- Move Feel++ singularity images ${SINGULARITYIMAGE} to FTP directory: ${FTPDIR}"
if [ ! -z ${FTPDIR} ]; then
    mv "${IMAGEDIR}/${SINGULARITYIMAGE}" "${FTPDIR}/${SINGULARITYIMAGE}"
fi
