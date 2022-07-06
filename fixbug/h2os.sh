#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/../bin.sh

romdir="$LOCALDIR/oppo"
systemdir="$TARGETDIR/system/system"
configdir="$TARGETDIR/config"
#build修复
id="$(cat $systemdir/build.prop | grep 'ro.rom.version=' | sed 's/ro.rom.version=//g')"
model="$(cat $TARGETDIR/vendor/build.prop |grep 'ro.product.vendor.model=' | sed 's/ro.product.vendor.model=//g')"
echo "当前系统版本号为:$id"
echo "当前机型为:$model"
echo "已将上述参数整合进build"
echo "
#设备参数
ro.product.model=$model
ro.build.display.id=$id
" >> $systemdir/build.prop

#cp -frp ./h2os/system/* $systemdir
