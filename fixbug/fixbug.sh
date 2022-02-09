#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/../bin.sh

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
    ./pixel.sh
    exit
    ;;
  "MIUI")
    ./miui.sh
    exit
    ;;
  "Flyme")
    ./flyme.sh
    exit
    ;;
  "ColorOS")
    ./oppo.sh
    exit
    ;;
  "OxygenOS")
    ./h2os.sh
    exit
    ;;
  *)
    echo "$os_type not supported!"
    exit  
    ;;
esac