#!/usr/bin/env bash

# Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -e


WSO2_AM_GW_VERSION=""
JDK_VERSION=""

BUILD_SCRIPT_DIR=$(dirname $(dirname $0))
source ${BUILD_SCRIPT_DIR}/configs

COLOR_REST="\e[0m"
COLOR_RED="\e[31m"

function echo_error() {
   echo "${COLOR_RED}$1${COLOR_REST}"
}

if ! cp ${BUILD_SCRIPT_DIR}/../dist/openjdk-${JDK_VERSION}.tar.gz ${BUILD_SCRIPT_DIR}/../resources; then
    echo_error "couldn't copy ${BUILD_SCRIPT_DIR}/../dist/openjdk-${JDK_VERSION}.tar.gz to ${BUILD_SCRIPT_DIR}/../resources"
    exit 1
fi

if [[ ! -f "${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip" ]]; then
    echo_error "${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip is not available"
    exit 1
fi

if ! unzip ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip; then
    echo_error "couldn't unzip the ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip"
    exit 1
fi

# import certificates
for entry in "${BUILD_SCRIPT_DIR}/../dist/certs"/*
do
  cert_file=$(basename -- "$entry")
  cert_name="${cert_file%.*}"
  keytool -import -alias ${cert_name} -keystore wso2am-micro-gw-${WSO2_AM_GW_VERSION}/lib/platform/bre/security/ballerinaTruststore.p12 -file ${entry} -storepass ballerina  -noprompt
done

if ! zip -r wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip wso2am-micro-gw-${WSO2_AM_GW_VERSION}/*;
 then
    echo_error "couldn't package wso2am-micro-gw-${WSO2_AM_GW_VERSION}/* to wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip"
    exit 1
fi

if ! cp wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip ${BUILD_SCRIPT_DIR}/../resources; then
    echo_error "couldn't copy wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip to ${BUILD_SCRIPT_DIR}/../resources"
    exit 1
fi

if ! rm -rf wso2am-micro-gw-${WSO2_AM_GW_VERSION}; then
    echo_error "couldn't remove wso2am-micro-gw-${WSO2_AM_GW_VERSION}"
    exit 1
fi

if ! rm -rf wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip; then
    echo_error "couldn't remove wso2am-micro-gw-${WSO2_AM_GW_VERSION}.zip"
    exit 1
fi

if ! sed -i.'' "s|JDK_VERSION|${JDK_VERSION}|g" ${BUILD_SCRIPT_DIR}/../bin/finalize ${BUILD_SCRIPT_DIR}/../bin/supply ${BUILD_SCRIPT_DIR}/../manifest.yml ; then
    echo_error "couldn't replace JDK_VERSION place holder"
    exit 1
fi

if ! sed -i.'' "s|WSO2_AM_GW_VERSION|${WSO2_AM_GW_VERSION}|g" ${BUILD_SCRIPT_DIR}/../bin/finalize  ${BUILD_SCRIPT_DIR}/../manifest.yml ; then
    echo_error "couldn't replace WSO2_AM_GW_VERSION place holder"
    exit 1
fi

test -f ${BUILD_SCRIPT_DIR}/../bin/finalize. && rm ${BUILD_SCRIPT_DIR}/../bin/finalize.
test -f ${BUILD_SCRIPT_DIR}/../bin/supply. && rm ${BUILD_SCRIPT_DIR}/../bin/supply.
test -f ${BUILD_SCRIPT_DIR}/../manifest.yml. && rm ${BUILD_SCRIPT_DIR}/../manifest.yml.

pushd ${BUILD_SCRIPT_DIR}/../
 if ! buildpack-packager build  -any-stack -cached; then
  echo_error "couldn't build the Build pack"
 fi

