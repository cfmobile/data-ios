#!/bin/bash

set -e
set -x

xcodebuild -destination platform='iOS Simulator',name="${XCODE_SIMULATOR_NAME}",OS="${XCODE_OS_VERSION}" -scheme PCFDataTests clean build test
