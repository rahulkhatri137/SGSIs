#!/bin/bash

# Inspired from url2GSI from ErfanGSIs tool at https://github.com/erfanoabdi/ErfanGSIs
# Copyright to Rahul at https://github.com/rahulkhatri137

LOCALDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $LOCALDIR
source $LOCALDIR/bin.sh
source $LOCALDIR/language_helper.sh
DL="${SCRIPTDIR}/dl.sh"
fixbug="--fix-bug"
dummy=false
build="AB"

usage() {
cat <<EOT
Usage:
$0 <Firmware link> <Firmware type> [Other args]
   Firmware link: Firmware download link or local path
   Firmware type: Firmware source type
   Example: <Firmware link> <Firmware type>:<SGSI Name>
   Other args:
    [-fb]: Don't Fix bugs in Rom
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
    --ab|-ab)
    build="AB"
    shift
    ;;
    --a|-a)
    build="A"
    shift
    ;;
    --fb|-fb)
    fixbug=""
    shift
    ;;
    --t|-t)
    dummy=true
    shift
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
TYPE=$1
shift

ORIGINAL_URL=$URL
if [[ $GTYPE == *":"* ]]; then
    NAME=`echo "$TYPE" | cut -d ":" -f 2`
else
    NAME=$TYPE
fi
if [[ $GTYPE == *":"* ]]; then
    TYPE=`echo "$TYPE" | cut -d ":" -f 1`
else
    TYPE=$TYPE
fi

if ! (cat $LOCALDIR/make/rom_support_list.txt | grep -qo "$TYPE");then
  echo $UNSUPPORTED_ROM
  echo $SUPPORTED_ROM_LIST
  cat $LOCALDIR/make/rom_support_list.txt
  exit 1
fi

rm -rf tmp output workspace SGSI
DOWNLOAD()
{
    URL="$1"
    ZIP_NAME="update.zip"
    mkdir -p "$TMPDIR"
    echo "-> Downloading firmware..."
    if echo "${URL}" | grep -q "mega.nz\|mediafire.com\|drive.google.com"; then
        ("${DL}" "${URL}" "$TMPDIR" "$ZIP_NAME") || exit 1
    else
        if echo "${URL}" | grep -q "1drv.ms"; then URL=${URL/ms/ws}; fi
        { type -p aria2c > /dev/null 2>&1 && aria2c -x16 -j$(nproc) -U "Mozilla/5.0" -d "$TMPDIR" -o "$ACTUAL_ZIP_NAME" ${URL} > /dev/null 2>&1; } || { wget -U "Mozilla/5.0" ${URL} -O "$TMPDIR/$ACTUAL_ZIP_NAME" > /dev/null 2>&1 || exit 1; }
        aria2c -x16 -j$(nproc) -U "Mozilla/5.0" -d "$TMPDIR" -o "$ACTUAL_ZIP_NAME" ${URL} > /dev/null 2>&1 || {
            wget -U "Mozilla/5.0" ${URL} -O "$TMPDIR/$ACTUAL_ZIP_NAME" > /dev/null 2>&1 || exit 1
        }
    fi
}
ZIP_NAME="$TMPDIR/dummy"
    if [[ "$URL" == "http"* ]]; then
        # URL detected
        ACTUAL_ZIP_NAME=update.zip
        ZIP_NAME="$LOCALDIR"/tmp/update.zip
        DOWNLOAD "$URL" "$ZIP_NAME"
        URL="$ZIP_NAME"
    fi

LEAVE() {
    echo "-> SGSI failed! Exiting..."
    rm -rf "$LOCALDIR/output" "$LOCALDIR/workspace" "$TMPDIR" "$LOCALDIR/SGSI"
    exit 1
}
  
 "$LOCALDIR"/make.sh $build $TYPE $NAME $URL $fixbug || LEAVE

rm -rf "$LOCALDIR/tmp"
rm -rf "$LOCALDIR/workspace"
rm -rf "$LOCALDIR/SGSI"
rm -rf "$MAKEDIR/system_patch/system/product"
if [ -d "$OUTDIR" ]; then
   cd $OUTDIR
   cp -fr Build*txt README.txt > /dev/null 2>&1 || LEAVE
   echo "-> Porting SGSI done!"
else
   LEAVE
fi
