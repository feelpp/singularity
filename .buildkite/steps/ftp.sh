#!/bin/bash

ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
while read line; do
    ${ROOTDIR}/../../push_image_ftp_server.sh $line
done < ${ROOTDIR}/../list
