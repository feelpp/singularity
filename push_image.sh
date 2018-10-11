#!/bin/bash
# This script push singularity images to the girder server. It simply
# Parse the container.yml file and extract information using a JSON and
# a YAML tool (jq, yq).
#
# The following environment variable must be set to push images:
#   GIRDER_API_KEY
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

# Create a token from GIRDER_API_KEY. This function set two variables
# GIRDER_CREDENTIALS_FILE
# GIRDER_TOKEN
# This function does not create a new token if a token exist. (use girder_token_delete)
girder_token_create()
{
    if [ ! -f ${GIRDER_CREDENTIALS_FILE-NONE} ]; then
        export GIRDER_CREDENTIALS_FILE=`mktemp`
        curl -s -X POST \
            -d '' \
            --header 'Content-Type: application/json' \
            --header 'Accept: application/json' \
            "${GIRDER_REPO_URL}/api/v1/api_key/token?key=${GIRDER_API_KEY}&duration=1" \
            > ${GIRDER_CREDENTIALS_FILE}
        export GIRDER_TOKEN=`cat "${GIRDER_CREDENTIALS_FILE}" | jq -rc .authToken.token`  #`girder_token`
    fi
}

girder_token_delete()
{
    if [ ${GIRDER_CREDENTIALS_FILE-NONE} != "NONE" ]; then
        if [ ! -f ${GIRDER_CREDENTIALS_FILE} ]; then
            curl -s -X DELETE \
                -d ${GIRDER_CREDENTIALS_FILE} \
                --header 'Accept: application/json' \
                "${GIRDER_REPO_URL}/api/v1/token/session" \
            rm -rf ${GIRDER_CREDENTIALS_FILE}
        fi
    fi
}

# Login to girder using a token.
# Token should be created first to get
# GIRDER_CREDENTIALS_FILE and GIRDER_TOKEN
girder_login()
{
    echo ""
    curl -s -X GET \
        -d ${GIRDER_CREDENTIALS_FILE} \
        --header 'Accept: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        "${GIRDER_REPO_URL}/api/v1/user/authentication"
    echo ""
}

# Logout from girder
girder_logout()
{
    echo ""
    curl -X DELETE \
        -d ${GIRDER_CREDENTIALS_FILE} \
        --header 'Accept: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        "${GIRDER_REPO_URL}/api/v1/user/authentication"
    echo ""
}

# Push the container using the girder-client. Note that the GIRDER_API_KEY env variable
# has to be set first.
girder_cli_simg_push()
{
    echo ""
    echo "-- Push item for : $SIMG  | ${1-NONE}"
    girder-cli \
        --host `echo "${GIRDER_REPO_URL}" | sed "s/https:\/\///"` \
        upload \
        ${GIRDER_FOLDER_PARENT_ID} \
        ${SIMG_DIR}/${SIMG}
    echo ""
}

# Push the container in the girder parent folder (See header note).
# This will create a girder item in the parent folder. Then upload the file
# in the parent item.
girder_simg_push()
{
    echo ""
    echo "-- Push item for : $SIMG  | ${1-NONE}"
    SIMG_SIZE=`wc -c < ${SIMG_DIR}/${SIMG}`
    curl -X POST \
        -d ${GIRDER_CREDENTIALS_FILE} \
        --header 'Content-Type: application/json' \
        --header 'Accept: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        "${GIRDER_REPO_URL}/api/v1/file?parentType=folder&parentId=${GIRDER_FOLDER_PARENT_ID}&name=${SIMG}&size=${SIMG_SIZE}" \
        --upload-file ${SIMG_DIR}/${SIMG}
    echo ""
}

# Search an item with the given container name (first arg) located in 
# girder parent folder id (See header note).
# First argument is the name of the item.
# return a JSON with girder item informations if found else a empty string.
girder_simg_info()
{
    echo ""
    curl -s -X GET \
        -d ${GIRDER_CREDENTIALS_FILE} \
        --header 'Accept: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        "${GIRDER_REPO_URL}/api/v1/item?folderId=${GIRDER_FOLDER_PARENT_ID}&name=${1-NONE}&limit=50&sort=lowerName&sortdir=1" \
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
    query=`girder_simg_info ${1-NONE}`
    echo $query | jq -cr ".${2-NONE}"
}

# Remove girder item from its id.
# First argument if item ID.
girder_simg_remove()
{
    echo ""
    echo "-- Remove item for : $SIMG  | ${1-NONE}"
    curl -X DELETE \
        -d ${GIRDER_CREDENTIALS_FILE} \
        --header 'Accept: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        "${GIRDER_REPO_URL}/api/v1/item/${1-NONE}"
    echo ""
}

# Move girder item to a new name.
# First argument is the item ID.
girder_simg_backup()
{
    echo ""
    echo "-- Backup item for : $SIMG  | ${1-"NONE"}"
    curl -X POST \
        -d ${GIRDER_CREDENTIALS_FILE} \
        --header 'Content-Type: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        --header 'Accept: application/json' \
        "${GIRDER_REPO_URL}/api/v1/item/${1-NONE}/copy?name=${SIMG}.bak"
    echo ""
}

clean_local_file()
{
    if [ -f ${SIMG_DIR}/${SIMG} ]; then
        rm -rf ${SIMG_DIR}/${SIMG}
    fi
}

echo "--- upload to singularity registry at cesga ${SIMG_MSO4SC_REGISTRY_NAME}:${SIMG_MSO4SC_REGISTRY_TAG}"
SREGISTRY_CLIENT=registry
echo "singularity run shub://sregistry.srv.cesga.es/mso4sc/sregistry:latest --quiet push --name ${SIMG_MSO4SC_REGISTRY_NAME} --tag ${SIMG_MSO4SC_REGISTRY_TAG} ${SIMG_DIR}/${SIMG}"
singularity run shub://sregistry.srv.cesga.es/mso4sc/sregistry:latest --quiet push --name ${SIMG_MSO4SC_REGISTRY_NAME} --tag ${SIMG_MSO4SC_REGISTRY_TAG} ${SIMG_DIR}/${SIMG}

echo "--- upload to Girder"
# Backup the file if it exists.
girder_token_create
girder_login
SIMG_ID=`girder_simg_info_get $SIMG "_id"`
if [ -n ${SIMG_ID} ]; then
    echo "yes"
    girder_simg_backup $SIMG_ID
    SIMG_BAK_ID=`girder_simg_info_get "$SIMG.bak" "_id"`
    girder_simg_remove $SIMG_ID
    #girder_simg_push $SIMG_ID
    girder_cli_simg_push $SIMG_ID
    girder_simg_remove $SIMG_BAK_ID
    clean_local_file
fi
girder_logout
girder_token_delete

# Example usage.
#girder_simg_info $SIMG
#girder_simg_info_get $SIMG "_id"
