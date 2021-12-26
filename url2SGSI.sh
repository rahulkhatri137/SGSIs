#!/bin/bash

# Inspired from url2GSI from ErfanGSIs tool at https://github.com/erfanoabdi/ErfanGSIs
# Copyright to Rahul at https://github.com/rahulkhatri137

LOCALDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DL="dl.sh"
fixbug=true
ver=12
build=AB

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
    --fb|-fb)
    fixbug=false
    shift
    ;;
    --ab|-ab)
    build=AB
    shift
    ;;
    --a|-a)
    build=A
    shift
    ;;
    --11|-11)
    ver=11
    shift
    ;;
    --12|-12)
    ver=12
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

if ! (cat $LOCALDIR/rom_support_list.txt | grep -qo "$TYPE");then
  echo "-> Rom type is not supported!"
  echo "Following are the supported types -"
  cat $LOCALDIR/other/rom_support_list.txt
  exit 1
fi

./clean.sh
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
        { type -p aria2c > /dev/null 2>&1 && aria2c -x16 -j$(nproc) -U "Mozilla/5.0" -d "$LOCALDIR/tmp" -o "$ACTUAL_ZIP_NAME" ${URL} > /dev/null 2>&1; } || { wget -U "Mozilla/5.0" ${URL} -O "$LOCALDIR/tmp/$ACTUAL_ZIP_NAME" > /dev/null 2>&1 || exit 1; }
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

LEAVE() {
    echo "-> SGSI failed! Exiting..."
    ./clean sh
    rm -rf "$LOCALDIR/output" "$LOCALDIR/tmp" "11/output" "12/output"
    exit 1
}

#Android 11 SGSI
if [ $ver == 11 ]; then
    mv tmp 11
    echo "export NAME=$N" >> 11/bin.sh
    "$LOCALDIR"/11/make.sh $build $TYPE update.zip  || LEAVE
fi

#Android 12 SGSI
if [ $ver == 12 ]; then
    mv tmp 12
    echo "export NAME=$N" >> 12/bin.sh
if [ $fixbug == true ]; then
    "$LOCALDIR"/12/make.sh --$build $TYPE update.zip --fix-bug || LEAVE
elif [ $fixbug == false ] ; then
    "$LOCALDIR"/12/make.sh --$build $TYPE update.zip || LEAVE
fi
fi

if [ -d "$LOCALDIR/11/output" ]; then
mv $LOCALDIR/11/output .
fi
if [ -d "$LOCALDIR/12/output" ]; then
mv $LOCALDIR/12/output .
fi

#Clean
./clean.sh

if [ -d "$LOCALDIR/output" ]; then
   cd output
   cp -fr B*txt README.txt > /dev/null 2>&1 || LEAVE
   echo "-> Porting SGSI done!"
else
   LEAVE
fi