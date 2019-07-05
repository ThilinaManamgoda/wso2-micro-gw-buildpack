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

COLOR_REST="\e[0m"
COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_PURPLE="\e[35m"

function echo_info() {
   echo -e "${COLOR_GREEN}-----> $1${COLOR_REST}"
}

function echo_error_exit() {
   echo -e "${COLOR_RED}$1${COLOR_REST}"
   exit 1
}

BUILD_SCRIPT_DIR=$(dirname $(dirname $0))
JDK="OpenJDK8U-jdk_x64_linux_hotspot_8u212b04"
WSO2_AM_GW_RUNTIME_VERSION="3.0.1"
WSO2_AM_GW_TOOLKIT_VERSION="3.0.1"
TRUST_STORE_PASSWORD="ballerina"

if ! cp ${BUILD_SCRIPT_DIR}/../dist/${JDK}.tar.gz ${BUILD_SCRIPT_DIR}/../resources; then
    echo_error_exit "Couldn't copy ${BUILD_SCRIPT_DIR}/../dist/${JDK}.tar.gz to ${BUILD_SCRIPT_DIR}/../resources"
fi

if [[ ! -f "${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip" ]]; then
    echo_error_exit "${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip is not available"
fi

if ! unzip ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip; then
    echo_error_exit "Couldn't unzip the ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip"
fi

if ! mkdir runtime; then
    echo_error_exit "Make directory runtime"
fi

if ! unzip -q ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/runtime.zip -d runtime ;
 then
    echo_error_exit "Couldn't unzip the ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip"
fi

# import certificates for runtime
for cert in "${BUILD_SCRIPT_DIR}/../dist/certs"/*
do
  cert_file=$(basename -- "$cert")
  cert_name="${cert_file%.*}"
  keytool -import -alias ${cert_name} -keystore ${BUILD_SCRIPT_DIR}/runtime/bre/security/ballerinaTruststore.p12 -file ${cert} -storepass ${TRUST_STORE_PASSWORD}  -noprompt
done

if ! zip -r runtime.zip runtime/*;
 then
    echo_error_exit "couldn't package runtime/* to runtime.zip"
fi

if ! cp ${BUILD_SCRIPT_DIR}/runtime.zip wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/; then
    echo_error_exit "Couldn't copy ${BUILD_SCRIPT_DIR}/runtime.zip to wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/"
fi

if ! zip -r wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/*;
 then
    echo_error_exit "couldn't package wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/* to wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip"
fi

#if ! rm -rf wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}; then
#    echo_error "couldn't remove wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}"
#    exit 1
#fi

if ! cp ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-toolkit-${WSO2_AM_GW_TOOLKIT_VERSION}.zip; then
    echo_error_exit "Couldn't copy ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-toolkit-${WSO2_AM_GW_TOOLKIT_VERSION}.zip"
fi

pushd ${BUILD_SCRIPT_DIR}/../
 if ! buildpack-packager build  -any-stack -cached; then
  echo_error "couldn't build the Build pack"
 fi