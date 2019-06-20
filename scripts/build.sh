#!/usr/bin/env bash

set -e

WSO2_AM_GW_VERSION=""
JDK_VERSION=""
CERTIFICATE=""

BUILD_SCRIPT_DIR=$(dirname $(dirname $0))
source ${BUILD_SCRIPT_DIR}/configs

if [[ ! -f "${BUILD_SCRIPT_DIR}/../resources/openjdk-${JDK_VERSION}.tar.gz" ]]; then
    echo "${BUILD_SCRIPT_DIR}/../resources/openjdk-${JDK_VERSION}.tar.gz is not available"
    exit 1
fi

if [[ ! -f "${BUILD_SCRIPT_DIR}/../resources/wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip" ]]; then
    echo "${BUILD_SCRIPT_DIR}/../resources/wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip is not available"
    exit 1
fi

if ! unzip ${BUILD_SCRIPT_DIR}/../resources/wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip; then
    echo "couldn't unzip the ${BUILD_SCRIPT_DIR}/../resources/wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip"
    exit 1
fi

if [[ -f "${BUILD_SCRIPT_DIR}/../resources/${CERTIFICATE}" ]]; then
 keytool -import -alias cf-am-micro-gw -keystore wso2am-micro-gw-${WSO2_AM_GW_VERSION}/lib/platform/bre/security/ballerinaTruststore.p12 -file ${BUILD_SCRIPT_DIR}/../resources/${CERTIFICATE} -storepass ballerina  -noprompt
 else
    echo "${BUILD_SCRIPT_DIR}/../resources/${CERTIFICATE} is not available"
    exit 1
fi

if ! zip -r wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip wso2am-micro-gw-${WSO2_AM_GW_VERSION}/*;
 then
    echo "couldn't package wso2am-micro-gw-${WSO2_AM_GW_VERSION}/* to wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip"
    exit 1
fi

if ! cp wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip ${BUILD_SCRIPT_DIR}/../resources; then
    echo "couldn't copy wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip to ${BUILD_SCRIPT_DIR}/../resources"
    exit 1
fi

if ! rm -rf wso2am-micro-gw-${WSO2_AM_GW_VERSION}; then
    echo "couldn't remove wso2am-micro-gw-${WSO2_AM_GW_VERSION}"
    exit 1
fi

if ! rm -rf wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip; then
    echo "couldn't remove wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip"
    exit 1
fi

if ! sed -i.'' "s|JDK_VERSION|${JDK_VERSION}|g" ${BUILD_SCRIPT_DIR}/../bin/finalize ${BUILD_SCRIPT_DIR}/../bin/supply; then
    echo "couldn't remove wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip"
    exit 1
fi

test -f ${BUILD_SCRIPT_DIR}/../bin/finalize. && rm ${BUILD_SCRIPT_DIR}/../bin/finalize.
test -f ${BUILD_SCRIPT_DIR}/../bin/supply. && rm ${BUILD_SCRIPT_DIR}/../bin/supply.