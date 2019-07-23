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

export SCRIPT_DIR=$(dirname $(dirname $0))
# Clean previous cached files
rm -rf blobs/*
rm config/blobs.yml
touch config/blobs.yml

# Upload blobs
bosh add-blob ${SCRIPT_DIR}/dist/cf_cli/cf-linux-amd64.tgz cf_cli/cf-linux-amd64.tgz
bosh add-blob ${SCRIPT_DIR}/dist/cf_cli/all_open.json cf_cli/all_open.json
bosh add-blob ${SCRIPT_DIR}/dist/wso2am-micro-gw_buildpack-cached-v1.0.0.zip micro_gateway_buildpack/wso2am-micro-gw_buildpack-cached-v1.0.0.zip

# Create the Bosh release
bosh create-release --tarball wso2am-micro-gw-buildpack-release.tgz --force