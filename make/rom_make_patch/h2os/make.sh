#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/../../../bin.sh
systemdir="$TARGETDIR/system/system"
configdir="$TARGETDIR/config"

# 为oneplus禁用向导的上下文 以保证在部分机型上发生的向导fc
sed -i '/ro.setupwizard.mode/d' $systemdir/etc/selinux/plat_property_contexts 
sed -i '/ro.setupwizard.mode/d' $systemdir/build.prop 
sed -i '/ro.setupwizard.mode/d' $systemdir/product/build.prop
sed -i '/setupwizard.feature.baseline_setupwizard_enabled/d' $systemdir/build.prop
sed -i '/setupwizard.feature.baseline_setupwizard_enabled/d' $systemdir/product/build.prop

# system patch 
cp -frp $LOCALDIR/system/* $systemdir
$LOCALDIR/gen_fs.sh
cat $LOCALDIR/contexts >> $configdir/system_file_contexts
cat $LOCALDIR/fs >> $configdir/system_fs_config
rm -rf $LOCALDIR/contexts $LOCALDIR/fs