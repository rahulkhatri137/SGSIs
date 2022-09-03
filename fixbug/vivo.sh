#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/../bin.sh

systemdir="$TARGETDIR/system/system"
configdir="$TARGETDIR/config"

cp -frp ./vivo/system/* $systemdir