#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/../bin.sh
source $TOOLDIR/language_helper.sh

romdir="$LOCALDIR/oppo"
systemdir="$TARGETDIR/system/system"
configdir="$TARGETDIR/config"
#build??
id="$(cat $systemdir/build.prop | grep 'ro.rom.version=' | sed 's/ro.rom.version=//g')"
model="$(cat $TARGETDIR/vendor/build.prop |grep 'ro.product.vendor.model=' | sed 's/ro.product.vendor.model=//g')"
echo "????????:$id"
echo "?????:$model"
echo "?????????build"
echo "
#????
ro.product.model=$model
ro.build.display.id=$id
" >> $systemdir/build.prop

#cp -frp ./h2os/system/* $systemdir
