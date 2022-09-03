#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/../bin.sh

systemdir="$TARGETDIR/system/system"
configdir="$TARGETDIR/config"

cp -frp ./myos/system/* $systemdir

# fs数据整合
cat ./myos/fs/fs >> $configdir/system_fs_config
cat ./myos/fs/contexts >> $configdir/system_file_contexts
cat ./myos/build >> $systemdir/build.prop