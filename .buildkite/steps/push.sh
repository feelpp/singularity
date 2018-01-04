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

# PUBLIC CONTAINERS
for id in ${PUBLIC_CONTAINERS_GIRDER_ID_LIST}
do
    eval ${PUBLIC_CONTAINERS_PARSE_EXPR} # create EXPR
    eval ${CONTAINERS_LIST} # create CLIST
    for cont in ${CLIST}
    do
	echo "push: $cont to girder public folder with ID: $id"
        ./push_image.sh -g $id $cont
    done
done

# PRIVATE CONTAINERS
for id in ${PRIVATE_CONTAINERS_GIRDER_ID_LIST}
do
    eval ${PRIVATE_CONTAINERS_PARSE_EXPR} # create EXPR
    eval ${CONTAINERS_LIST} # create CLIST
    for cont in ${CLIST}
    do
	echo "push: $cont to girder private folder with ID: $id"
        ./push_image.sh -g $id $cont
    done
done
