#!/bin/bash

# Copyright (C) 2020 Xiaoxindada <2245062854@qq.com>

LOCALDIR=`cd "$( dirname $0 )" && pwd`
cd $LOCALDIR
source ./bin.sh

Usage() {
cat <<EOT
Usage:
$0 AB|ab or $0 A|a
EOT
}

mkdir -p ./tmp
chmod -R 777 ./
chown -R root:root ./
./workspace_cleanup.sh > /dev/null 2>&1
firmware=$1

if [[ $firmware == system.img ]]; then
echo "- Already system image"
mv $firmware $LOCALDIR/
exit 0
fi

rm -rf ./*.img
echo "┠ Extracting Firmware..."
if [ -e $firmware ];then
    ./Firmware_extractor/extractor.sh $firmware $TMPDIR  > /dev/null 2>&1 || { echo "> Failed to extract firmware" && exit 1; }
  fi
  if [ -e $TMPDIR/$firmware ];then
       ./Firmware_extractor/extractor.sh "$TMPDIR/$firmware" "$TMPDIR/" > /dev/null 2>&1 || { echo "> Failed to extract firmware" && exit 1; }
  fi

cd ./tmp
if [ -e ./system.img ];then
  mv ./*.img ../
fi
exit 0
