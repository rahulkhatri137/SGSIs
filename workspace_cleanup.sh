#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source ./language_helper.sh

mkdir -p ./tmp
echo "CLEANINGWORKSPACE"
if [ -e ./tmp/*.bin ];then
  rm -rf ./tmp/*.bin
fi
