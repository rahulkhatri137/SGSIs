#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/../../../bin.sh

systemdir="$TARGETDIR/system/system"
configdir="$TARGETDIR/config"

# Skip Setup Wizard for Pixel 
echo "" >> $systemdir/build.prop
echo "# Skip Setup Wizard" >> $systemdir/build.prop
echo "ro.setupwizard.mode=DISABLED" >> $systemdir/build.prop

echo "" >> $systemdir/product/etc/build.prop
echo "# Skip Setup Wizard" >> $systemdir/product/build.prop
echo "ro.setupwizard.mode=DISABLED" >> $systemdir/product/build.prop

echo "" >> $systemdir/system_ext/etc/build.prop
echo "# Skip Setup Wizard" >> $systemdir/system_ext/build.prop
echo "ro.setupwizard.mode=DISABLED" >> $systemdir/system_ext/build.prop

# 清空pixel无用的上下文导致的启动至rec
if [ -e $systemdir/product/etc/selinux/mapping ];then
  true > $systemdir/product/etc/selinux/product_property_contexts
fi
