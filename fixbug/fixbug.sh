#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/../bin.sh
source $LOCALDIR/../language_helper.sh

./rm.sh > /dev/null 2>&1

os_type="$1"

echo "
--------------------

$SUPPORTED_ROM_STR:

Pixel
MIUI
Flyme
ColorOS
--------------------
"
case "$os_type" in
  "Pixel")
    echo "$FIXING_STR"
    ./pixel.sh
    exit
    ;;
  "MIUI")
    echo "$FIXING_STR"
    ./miui.sh
    exit
    ;;
  "Flyme")
    echo "$FIXING_STR"
    ./flyme.sh
    exit
    ;;
  "ColorOS")
    echo "$FIXING_STR"
    ./oppo.sh
    exit
    ;;
  "OxygenOS")
    echo "$FIXING_STR"
    ./h2os.sh
    exit
    ;;
  *)
    echo "$os_type $NOT_SUPPORT_FIX_BUG"
    exit  
    ;;
esac