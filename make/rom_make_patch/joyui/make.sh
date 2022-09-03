#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/../../../bin.sh

systemdir="$TARGETDIR/system/system"
configdir="$TARGETDIR/config"

# system patch 
cp -frp $LOCALDIR/system/* $systemdir
cat $LOCALDIR/contexts >> $configdir/system_file_contexts
cat $LOCALDIR/fs >> $configdir/system_fs_config
