#!/bin/bash
# Author(s) G. Dollé <dolle@math.unistra.fr>
#
# This script use 'yq' ('jq' like script) to parse the yaml file
# and select keyword.
# The "container.yml" is parsed, then containers are pushed in the
# parent folder girder id.

set -x
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
source ${SCRIPT_DIR}/include.sh

PROJECT=`sed -e 's/^"//' -e 's/"$//' <<<"${PROJECT}"`
for i in ${PROJECT}; do 
    CONTAINER="feelpp/${i}:${TAG}"
    # ensure that the container is present
    docker pull ${CONTAINER}
    echo "Generate recipe: ${CONTAINER} to girder folder with ID: ${GIRDER_ID}"
    ./generate_recipe.sh -g ${GIRDER_ID} ${CONTAINER}
done
