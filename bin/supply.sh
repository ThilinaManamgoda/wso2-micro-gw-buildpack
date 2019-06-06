#!/usr/bin/env bash

set -euo pipefail

APP_DIR=$1
CACHE_DIR=$2
DEPS_DIR=$3
DEPS_IDX=$4

export BUILD_PACK_DIR=`dirname $(readlink -f ${BASH_SOURCE%/*})`

#  creates a directory for storing deps
if ! mkdir -p ${DEPS_DIR}/${DEPS_IDX};
 then
    echo  "couldn't create the directory ${DEPS_DIR}/${DEPS_IDX}"
    exit 1
fi

