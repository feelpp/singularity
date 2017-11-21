#!/bin/bash

ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
while read line; do
    ${ROOTDIR}/../../generate_image.sh $line
done < ${ROOTDIR}/../list
