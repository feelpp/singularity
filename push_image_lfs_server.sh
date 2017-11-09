#!/bin/bash
# Script to push generated singularity images into the laboratory
# gitlab server. Gitlab LFS is used to store images (binaries)
# Usage: ./push_image_lfs_server.sh <image:branch>

set -euo pipefail

source include_path.sh

REPO_NAME=feelpp-singularity-images.git
REPO=git@gitlab.math.unistra.fr:feelpp/feelpp-singularity-images.git
REPO_MAX_IMAGES=20 #( x10 GB )

# Clone/update gitlab repository.
echo "-- Clone Feel++ singularity images repository"
if [ -d ${REPO_NAME} ]; then
    cd ${REPO_NAME}
    git lfs pull
    git pull
    cd ${ROOT_DIR}
else
    git lfs clone --depth=1 ${REPO} ${REPO_NAME}
fi

# Move (overide) generated images in the repository.
rsync --remove-source-files "${IMAGEDIR}/${SINGULARITYIMAGE}" "${REPO_NAME}/${SINGULARITYIMAGE}"

cd ${REPO_NAME}
echo "-- Push Feel++ singularity images"
git add *.img
git commit -am "[buildkite] Deploy new singularity images"
git lfs push origin master
git push
cd ${ROOT_DIR}
