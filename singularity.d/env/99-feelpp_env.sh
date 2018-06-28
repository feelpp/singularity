#!/usr/bin/env bash

#cd ${FEELPP_TUTORIAL}
#. ${FEELPP_TUTORIAL}/feelpp.env.sh
#. ${FEELPP_TUTORIAL}/feelpp.conf.sh
#. /usr/local/bin/start.sh
export OPENBLAS_NUM_THREADS=1
export OPENBLAS_VERBOSE=0
$(cat /etc/bash.bashrc | tail -2  | head -1)
