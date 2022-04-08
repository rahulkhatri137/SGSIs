#!/bin/bash

LOCALDIR=`cd "$( dirname $0 )" && pwd`
cd $LOCALDIR

mkdir -p ./tmp
echo "正在清理工作目录"
if [ -e ./tmp/*.bin ];then
  rm -rf ./tmp/*.bin
fi