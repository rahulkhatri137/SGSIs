#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR

source $LOCALDIR/../bin.sh
source $TOOLDIR/language_helper.sh

systemdir="$TARGETDIR/system/system"
configdir="$TARGETDIR/config"
bin="../bin"
signapk_tools_dir="$bin/tools/signapk"

cp -frp ./flyme/system/* $systemdir

# Merge FS DATA
cat ./flyme/fs/fs >> $configdir/system_fs_config
cat ./flyme/fs/contexts >> $configdir/system_file_contexts
