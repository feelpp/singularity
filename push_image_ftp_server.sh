#!/bin/bash
# Script to push generated singularity images into the laboratory
# gitlab server. Gitlab LFS is used to store images (binaries)
# Script arguments must be a list of docker container names, for example:
# ./singularity-push.sh feelpp/feelpp-crb:latest feelpp/feelpp-toolboxes:latest

set -euo pipefail

source include_path.sh

# Copy (overide) generated images in the repository.
echo "-- Move Feel++ singularity images to FTP directory"
if [ ! -z ${FTPDIR} ]
    mv "${IMAGEDIR}/${SINGULARITYIMAGE}" "${FTPDIR}/"
fi
