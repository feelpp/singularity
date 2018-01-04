#!/bin/bash
# This script push singularity images to the girder server. It simply
# Parse the container.yml file and extract information using a JSON and
# a YAML tool (jq, yq).
#
# The following environment variable must be set to push images:
#   GIRDER_TOKEN
#   GIRDER_REPO_URL
#
# Usage: $push_image -g <girder_parent_folder_id> <base/image:tag>
#
# Requirements: jq / yq  tools

#set -x
set -euo pipefail

source include.sh

# Check if image has been generated.
if [ ! -f ${SIMG_DIR}/${SIMG} ]; then
    echo "${SIMG_DIR}/${SIMG} does not exist !"
fi

SIMG_SIZE=`wc -c < ${SIMG_DIR}/${SIMG}`

# Push the container in the girder parent folder (See header note).
# This will create a girder item in the parent folder. Then upload the file
# in the parent item.
girder_simg_push()
{
    echo "-- Push item for : $SIMG  | ${1-none}"
    curl -X POST \
        --progress-bar \
        --header 'Content-Type: application/json' \
        --header 'Accept: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        "${GIRDER_REPO_URL}/api/v1/file?parentType=folder&parentId=${GIRDER_FOLDER_PARENT_ID}&name=${SIMG}&size=${SIMG_SIZE}" \
        --upload-file ${SIMG_DIR}/${SIMG}
    echo ""
}

girder_cli_simg_push()
{
    echo "-- Push item for : $SIMG  | ${1-none}"
    girder-cli \
        --api-key ${GIRDER_TOKEN} \
        --host `echo "${GIRDER_REPO_URL}" | sed "s/https:\/\///"` \
        upload \
        ${GIRDER_FOLDER_PARENT_ID} \
        ${SIMG_DIR}/${SIMG}
    echo ""
}

# Search an item with the given container name (first arg) located in 
# girder parent folder id (See header note).
# First argument is the name of the item.
# return a JSON with girder item informations if found else a empty string.
girder_simg_info()
{
    curl -s -X GET \
        --header 'Accept: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        "${GIRDER_REPO_URL}/api/v1/item?folderId=${GIRDER_FOLDER_PARENT_ID}&name=${1-none}&limit=50&sort=lowerName&sortdir=1" \
    | jq -c '.[]'
    echo ""
}

# Search the container in girder
# First argument is the item name
# Second argument is item metadata key.
# Return the value for the given key as first argument
# See girder_simg_info for all keys.
girder_simg_info_get()
{
    query=`girder_simg_info ${1-none}`
    echo $query | jq -cr ".${2-none}"
    echo ""
}

# Remove girder item from its id.
# First argument if item ID.
girder_simg_remove()
{
    echo "-- Remove item for : $SIMG  | ${1-none}"
    curl -X DELETE \
        --header 'Accept: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        "${GIRDER_REPO_URL}/api/v1/item/${1-none}"
    echo ""
}

# Move girder item to a new name.
# First argument is the item ID.
girder_simg_backup()
{
    echo "-- Backup item for : $SIMG  | ${1-"none"}"
    curl -X POST \
        -d "" \
        --header 'Content-Type: application/json' \
        --header 'Accept: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        "${GIRDER_REPO_URL}/api/v1/item/${1-none}/copy?name=${SIMG}.bak"
    echo ""
}

clean_local_file()
{
    if [ -f ${SIMG_DIR}/${SIMG} ]; then
        rm -rf ${SIMG_DIR}/${SIMG}
    fi
}

SIMG_ID=`girder_simg_info_get $SIMG "_id"`

# Backup the file if it exists.
if [ -n ${SIMG_ID} ]; then
    girder_simg_backup $SIMG_ID
    SIMG_BAK_ID=`girder_simg_info_get "$SIMG.bak" "_id"`
    girder_simg_remove $SIMG_ID
    #girder_simg_push $SIMG_ID
    girder_cli_simg_push $SIMG_ID
    girder_simg_remove $SIMG_BAK_ID
    clean_local_file
fi

# Example usage.
#girder_simg_info $SIMG
#girder_simg_info_get $SIMG "_id"
