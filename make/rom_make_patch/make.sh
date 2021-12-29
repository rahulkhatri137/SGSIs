#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/../../bin.sh
source $TOOLDIR/language_helper.sh

configdir="$TARGETDIR/config"
systemdir="$TARGETDIR/system/system"

echo "-> $FIXING_ROM"
$DEBLOATDIR/pixel.sh "$systemdir" > /dev/null 2>&1 
