#!/bin/bash
set -euo pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
BUILD_PATH="$SCRIPTPATH/../../build"
BUILD_BIN="$BUILD_PATH/bin"

BINARY_NAME="ec2-instance-selector-linux-amd64"
LICENSE_TEST_TAG="aeis-license-test"
LICENSE_REPORT_FILE="$BUILD_PATH/license-report"

SUPPORTED_PLATFORMS_LINUX="linux/amd64" make -s -f $SCRIPTPATH/../../Makefile build-binaries
docker buildx build --load -t $LICENSE_TEST_TAG $SCRIPTPATH/
docker run -i -e GITHUB_TOKEN --rm -v $SCRIPTPATH/:/test -v $BUILD_BIN/:/aeis-bin $LICENSE_TEST_TAG golicense /test/license-config.hcl /aeis-bin/$BINARY_NAME | tee $LICENSE_REPORT_FILE
$SCRIPTPATH/check-licenses.sh $LICENSE_REPORT_FILE
