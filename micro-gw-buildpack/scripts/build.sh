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
JDK=""
WSO2_AM_GW_RUNTIME_VERSION=""
WSO2_AM_GW_TOOLKIT_VERSION=""
TRUST_STORE_PASSWORD=""

source ${BUILD_SCRIPT_DIR}/config

if ! cp ${BUILD_SCRIPT_DIR}/../dist/${JDK}.tar.gz ${BUILD_SCRIPT_DIR}/../resources; then
    echo_error_exit "Couldn't copy ${BUILD_SCRIPT_DIR}/../dist/${JDK}.tar.gz to ${BUILD_SCRIPT_DIR}/../resources"
fi

if ! cp ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-toolkit-${WSO2_AM_GW_TOOLKIT_VERSION}.zip ${BUILD_SCRIPT_DIR}/../resources; then
    echo_error_exit "Couldn't copy ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-toolkit-${WSO2_AM_GW_TOOLKIT_VERSION}.zip to ${BUILD_SCRIPT_DIR}/../resources"
fi

if [[ ! -f "${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip" ]]; then
    echo_error_exit "${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip is not available"
fi

if ! unzip -q ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip; then
    echo_error_exit "Couldn't unzip the ${BUILD_SCRIPT_DIR}/../dist/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip"
fi

cp ${BUILD_SCRIPT_DIR}/../dist/conf/micro-gw.conf ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/conf/

pushd ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}
    if ! unzip -q runtime.zip -d runtime;
     then
        echo_error_exit "Couldn't unzip the ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/runtime.zip"
    fi
    if ! rm runtime.zip; then
        echo_error_exit "Couldn't remove ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/runtime.zip"
    fi
popd

# import certificates for runtime
for cert in "${BUILD_SCRIPT_DIR}/../dist/certs"/*
do
  cert_file=$(basename -- "$cert")
  cert_name="${cert_file%.*}"
  if ! keytool -import -alias ${cert_name} -keystore ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/runtime/bre/security/ballerinaTruststore.p12 -file ${cert} -storepass ${TRUST_STORE_PASSWORD}  -noprompt;
   then
    echo_error_exit "Couldn't import the certificate: ${cert_file}"
  fi
done

keytool -delete -noprompt -alias wso2apim  -keystore ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/runtime/bre/security/ballerinaTruststore.p12 -storepass ${TRUST_STORE_PASSWORD}
keytool -import -alias wso2apim -keystore ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/runtime/bre/security/ballerinaTruststore.p12 -file ${BUILD_SCRIPT_DIR}/../dist/jwt_cert/jwt.crt -storepass ${TRUST_STORE_PASSWORD}  -noprompt


pushd ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/runtime
    if ! zip -q -r runtime.zip .; then
       echo_error_exit "Couldn't package runtime/* to runtime.zip"
    fi
popd

if ! mv ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/runtime/runtime.zip ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/; then
  echo_error_exit "Couldn't move runtime.zip to ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/"
fi

if ! rm -rf ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/runtime; then
  echo_error_exit "Couldn't remove ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/runtime"
fi

pushd ${BUILD_SCRIPT_DIR}
    if ! zip -q -r wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/*; then
        echo_error_exit "Couldn't package wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}/* to wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip"
    fi
popd

if ! cp ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip ${BUILD_SCRIPT_DIR}/../resources; then
    echo_error_exit "Couldn't copy ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip to ${BUILD_SCRIPT_DIR}/../resources"
fi

if ! rm -rf ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}; then
    echo_error_exit "Couldn't remove ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}"
fi

if ! rm  ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip; then
    echo_error_exit "Couldn't remove ${BUILD_SCRIPT_DIR}/wso2am-micro-gw-linux-${WSO2_AM_GW_RUNTIME_VERSION}.zip"
fi

pushd ${BUILD_SCRIPT_DIR}/../
 if ! buildpack-packager build  -any-stack; then
  echo_error_exit "Couldn't build the Build pack"
 fi
popd
#
#cf delete-buildpack -f wso2am-micro-gw
#cf create-buildpack wso2am-micro-gw /Users/wso2/projects/ix/pcf/buildpack-project/buildpack-m3/micro-gw-buildpack/wso2am-micro-gw_buildpack-v1.0.0.zip  0 --enable
