#!/bin/sh

#  FSUpload.sh
#  UploadApp
#
#  Created by 方世沛 on 2018/12/7.
#  Copyright © 2018 方世沛. All rights reserved.
echo "*********************************"
echo "Build Started"
echo "*********************************"

echo "*********************************"
echo "Beginning Build Process"
echo "*********************************"

xcodebuild -workspace "${1}" -sdk iphoneos -scheme "${4}" -configuration "${6}" CONFIGURATION_BUILD_DIR="${3}"
echo "xcodebuild -workspace '${1}' -target '${2}' -sdk iphoneos -scheme '${4}' -configuration '${6}' CONFIGURATION_BUILD_DIR='${3}'"

echo "*********************************"
echo "Creating IPA"
echo "*********************************"

/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${3}/${4}.app" -o "${5}/${4}.ipa"
