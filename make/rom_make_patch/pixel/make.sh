#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/../../../bin.sh

systemdir="$TARGETDIR/system/system"
configdir="$TARGETDIR/config"

# 清空pixel无用的上下文导致的启动至rec
if [ -e $systemdir/product/etc/selinux/mapping ];then
  true > $systemdir/product/etc/selinux/product_property_contexts
fi
