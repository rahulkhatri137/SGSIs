#!/bin/bash

# Inspired from url2GSI from ErfanGSIs tool at https://github.com/erfanoabdi/ErfanGSIs
# Copyright to Rahul at https://github.com/rahulkhatri137

LOCALDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ./bin.sh
source ./language_helper.sh
DL="${SCRIPTDIR}/dl.sh"

usage() {
cat <<EOT
Usage:
    $0 <Firmware link> <Firmware type>
    Firmware link: Firmware download link or local path
    Firmware type: Firmware source type
    Example: <Firmware link> <Firmware type>:<SGSI Name>
EOT
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --help|-h|-?)
    usage
    exit 1
    ;;
    *)
    POSITIONAL+=("$1")
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ ! -n $2 ]]; then
    echo "-> ERROR!"
    echo " - Enter all needed parameters"
    usage
    exit 1
fi

URL=$1
shift
GTYPE=$1
shift

ORIGINAL_URL=$URL
if [[ $GTYPE == *":"* ]]; then
    N=`echo "$GTYPE" | cut -d ":" -f 2`
else
    N=$GTYPE
fi
if [[ $GTYPE == *":"* ]]; then
    TYPE=`echo "$GTYPE" | cut -d ":" -f 1`
else
    TYPE=$GTYPE
fi

if ! (cat $LOCALDIR/make/rom_support_list.txt | grep -qo "$TYPE");then
  echo $UNSUPPORTED_ROM
  echo $SUPPORTED_ROM_LIST
  cat $LOCALDIR/make/rom_support_list.txt
  exit 1
fi

echo "export NAME=$N" >> bin.sh
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
   "$LOCALDIR"/make.sh --AB $TYPE update.zip --fix-bug

sudo rm -rf "$LOCALDIR/tmp"
sudo rm -rf "$LOCALDIR/workspace"
sudo rm -rf "$LOCALDIR/SGSI"
if [ -d "$OUTDIR" ]; then
   echo "-> Porting SGSI done!"
else
   echo "-> SGSI not found! Exiting..."
   exit 1
fi