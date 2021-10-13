#!/bin/bash

LOCALDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ./bin.sh
source ./language_helper.sh
DL="${SCRIPTDIR}/dl.sh"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    *)
    POSITIONAL+=("$1")
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

URL=$1
shift
TYPE=$1
shift

ORIGINAL_URL=$URL
if [[ $TYPE == *":"* ]]; then
    NAME=`echo "$TYPE" | cut -d ":" -f 2`
else
    NAME=$TYPE
fi
date=`date +%Y%m%d`

DOWNLOAD()
{
    URL="$1"
    ZIP_NAME="update.zip"
    mkdir -p "$LOCALDIR/tmp"
    echo "-> Downloading firmware..."
    if echo "${URL}" | grep -q "mega.nz\|mediafire.com\|drive.google.com"; then
        ("${DL}" "${URL}" "$LOCALDIR/tmp" "$ZIP_NAME") || exit 1
    else
        if echo "${URL}" | grep -q "1drv.ms"; then URL=${URL/ms/ws}; fi
        { type -p aria2c > /dev/null 2>&1 && aria2c -x16 -j$(nproc) -U "Mozilla/5.0" -d "$LOCALDIR/input" -o "$ACTUAL_ZIP_NAME" ${URL} > /dev/null 2>&1; } || { wget -U "Mozilla/5.0" ${URL} -O "$LOCALDIR/input/$ACTUAL_ZIP_NAME" > /dev/null 2>&1 || exit 1; }
        aria2c -x16 -j$(nproc) -U "Mozilla/5.0" -d "$LOCALDIR/tmp" -o "$ACTUAL_ZIP_NAME" ${URL} > /dev/null 2>&1 || {
            wget -U "Mozilla/5.0" ${URL} -O "$LOCALDIR/tmp/$ACTUAL_ZIP_NAME" > /dev/null 2>&1 || exit 1
        }
    fi
}
ZIP_NAME="$LOCALDIR/tmp/dummy"
    if [[ "$URL" == "http"* ]]; then
        # URL detected
        ACTUAL_ZIP_NAME=update.zip
        ZIP_NAME="$LOCALDIR"/tmp/update.zip
        DOWNLOAD "$URL" "$ZIP_NAME"
        URL="$ZIP_NAME"
    fi
   "$LOCALDIR"/make.sh --AB Generic update.zip --fix-bug

sudo rm -rf "$LOCALDIR/tmp"
sudo rm -rf "$LOCALDIR/workspace"
sudo rm -rf "$LOCALDIR/SGSI"
sudo mv "$LOCALDIR/output/system.img" "$LOCALDIR/output/$NAME-AB-$date-RK137SGSI.img"
echo "-> Porting SGSI done!"
