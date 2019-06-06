#!/usr/bin/env bash

APP_DIR=$1
source "${APP_DIR}/wso2-am-gw"

echo "default_process_types:"
echo "  web: ${APP_DIR}/${PROJECT_NAME}/bin/gateway"