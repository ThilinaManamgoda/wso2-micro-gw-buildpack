#!/usr/bin/env bash

set -euo pipefail

APP_DIR=$1
CACHE_DIR=$2
DEPS_DIR=$3
DEPS_IDX=$4
PROFILE_DIR=${5:-}


export BUILD_PACK_DIR=`dirname $(readlink -f ${BASH_SOURCE%/*})`
WSO2_AM_GW="wso2am-micro-gw-2.6.0"

# parameters for micro gateway
PROJECT_NAME=""
API_NAME=""
VERSION=""
USER_NAME=""
PASSWORD=""

source "${APP_DIR}/wso2-am-gw"

if ! unzip -d ${BUILD_PACK_DIR}/base ${BUILD_PACK_DIR}/base/${WSO2_AM_GW}.zip;
 then
    echo "unable to unzip ${WSO2_AM_GW}.zip"
    exit 1
fi
if ! ${BUILD_PACK_DIR}/base/${WSO2_AM_GW}/bin/micro-gw setup ${PROJECT_NAME} -a ${API_NAME} -v ${VERSION} -u ${USER_NAME} -p ${PASSWORD} -t lib/platform/bre/security/ballerinaTruststore.p12 -w wso2carbon;
then
    echo "unable to create the project: ${PROJECT_NAME}"
    exit 1
fi

if ! ${BUILD_PACK_DIR}/base/${WSO2_AM_GW}/bin/micro-gw build ${PROJECT_NAME};
then
    echo "unable to create the project: ${PROJECT_NAME}"
    exit 1
fi

if ! unzip -d ${APP_DIR} $(pwd)/${PROJECT_NAME}/target/micro-gw-${PROJECT_NAME}.zip;
 then
   echo "unable to unzip the project zip: micro-gw-${PROJECT_NAME}.zip"
   exit 1
fi

if ! sed -i "s/9095/\$\{PORT\}/" ${APP_DIR}/micro-gw-${PROJECT_NAME}/micro-gw.conf;
 then
   echo "unable to configure the PORT env"
   exit 1
fi
