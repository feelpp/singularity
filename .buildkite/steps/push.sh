#!/bin/bash
# Author(s) G. Dollé <dolle@math.unistra.fr>
#
# This script use 'yq' ('jq' like script) to parse the yaml file
# and select keyword.
# The "container.yml" is parsed, then containers are pushed in the
# parent folder girder id.

#set -x
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
source ${SCRIPT_DIR}/include.sh

GIRDER_ID=`sed -e 's/^"//' -e 's/"$//' <<<"${GIRDER_ID}"`
CONTAINER="feelpp/${PROJECT}:${TAG}"
echo "push: ${CONTAINER} to girder public with ID: ${GIRDER_ID}"
./push_image.sh -g ${GIRDER_ID} ${CONTAINER}
