#!/usr/bin/env bash

set -e

GREEN_BOLD="\e[1m\e[32m"

WSO2_AM_GW_VERSION=""
JDK_VERSION=""
CERTIFICATE=""

BUILD_SCRIPT_DIR=$(dirname $(dirname $0))
source ${BUILD_SCRIPT_DIR}/configs

if ! cp ${BUILD_SCRIPT_DIR}/../dist/openjdk-${JDK_VERSION}.tar.gz ${BUILD_SCRIPT_DIR}/../resources; then
    echo "cannot copy ${BUILD_SCRIPT_DIR}/../dist/openjdk-${JDK_VERSION}.tar.gz to ${BUILD_SCRIPT_DIR}/../resources"
    exit 1
fi

if [[ ! -f "${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip" ]]; then
    echo "${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip is not available"
    exit 1
fi

if ! unzip ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip; then
    echo "couldn't unzip the ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip"
    exit 1
fi

if [[ -f "${BUILD_SCRIPT_DIR}/../dist/${CERTIFICATE}" ]]; then
 keytool -import -alias cf-am-micro-gw -keystore wso2am-micro-gw-${WSO2_AM_GW_VERSION}/lib/platform/bre/security/ballerinaTruststore.p12 -file ${BUILD_SCRIPT_DIR}/../dist/${CERTIFICATE} -storepass ballerina  -noprompt
 else
    echo "${BUILD_SCRIPT_DIR}/../dist/${CERTIFICATE} is not available"
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

if ! sed -i.'' "s|JDK_VERSION|${JDK_VERSION}|g" ${BUILD_SCRIPT_DIR}/../bin/finalize ${BUILD_SCRIPT_DIR}/../bin/supply ${BUILD_SCRIPT_DIR}/../manifest.yml ; then
    echo "couldn't replace JDK_VERSION place holder"
    exit 1
fi

if ! sed -i.'' "s|WSO2_AM_GW_VERSION|${WSO2_AM_GW_VERSION}|g" ${BUILD_SCRIPT_DIR}/../bin/finalize  ${BUILD_SCRIPT_DIR}/../manifest.yml ; then
    echo "couldn't replace JDK_VERSION place holder"
    exit 1
fi

test -f ${BUILD_SCRIPT_DIR}/../bin/finalize. && rm ${BUILD_SCRIPT_DIR}/../bin/finalize.
test -f ${BUILD_SCRIPT_DIR}/../bin/supply. && rm ${BUILD_SCRIPT_DIR}/../bin/supply.
test -f ${BUILD_SCRIPT_DIR}/../bin/manifest.yml. && rm ${BUILD_SCRIPT_DIR}/../bin/manifest.yml.

echo "${GREEN_BOLD}Done !. Please find the build pack ${BUILD_SCRIPT_DIR}/../wso2-am-micro-gw_buildpack-cached-v1.0.0.zip"