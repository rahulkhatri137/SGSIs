#!/bin/bash

# Inspired from url2GSI from ErfanGSIs tool at https://github.com/erfanoabdi/ErfanGSIs
# Copyright to Rahul at https://github.com/rahulkhatri137

LOCALDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $LOCALDIR
source $LOCALDIR/bin.sh
DL="${SCRIPTDIR}/dl.sh"
image=false
build="AB"

Usage() {
cat <<EOT
Usage:
$0 <Firmware link> <Firmware type> [Other args]
   Firmware link: Firmware download link or local path
   Firmware type: Firmware source type
   Example: <Firmware link> <Firmware type>:<SGSI Name>
   Other args:
    [i]: Build image only(Processed/Failed)
EOT
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --help|-h|-?)
    Usage
    exit 1
    ;;
    --ab|-ab)
    build="AB"
    shift
    ;;
    --a|-a)
    echo "- A-only SGSI not supported"
    exit 1
    shift
    ;;
    --t|-t)
    dummy=true
    shift
    ;;
    --i|-i)
    image=true
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
    echo "> ERROR!"
    echo " - Enter all needed parameters"
    usage
    exit 1
fi

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
if [[ $TYPE == *":"* ]]; then
    TYPE=`echo "$TYPE" | cut -d ":" -f 1`
else
    TYPE=$TYPE
fi

if [[ $NAME == *"-"* ]]; then
    GNAME=`echo "$NAME" | cut -d "-" -f 1`
else
    GNAME=$NAME
fi

if ! (cat $MAKEDIR/type_support_list.txt | grep -qo "$TYPE");then
  echo "> Firmware type is not supported!"
  echo "─ Following are the supported types -"
  cat $MAKEDIR/type_support_list.txt
  exit 1
fi

if [[ $TYPE == "Generic" ]]; then
if ! (cat $MAKEDIR/rom_support_list.txt | grep -qo "$GNAME");then
  echo "> Rom type is not supported!"
  echo "─ Following are the supported types -"
  cat $MAKEDIR/rom_support_list.txt
  exit 1
fi
fi

rm -rf output
DOWNLOAD()
{
    URL="$1"
    ZIP_NAME="update.zip"
    rm -rf $TMPDIR $TARGETDIR
    mkdir -p "$TMPDIR"
    echo "┠ Downloading firmware..."
    if echo "${URL}" | grep -q "mega.nz\|mediafire.com\|drive.google.com"; then
        ("${DL}" "${URL}" "$TMPDIR" "$ZIP_NAME") || exit 1
    else
        if echo "${URL}" | grep -q "1drv.ms"; then URL=${URL/ms/ws}; fi
        { type -p aria2c > /dev/null 2>&1 && aria2c -x16 -j$(nproc) -U "Mozilla/5.0" -d "$TMPDIR" -o "$ACTUAL_ZIP_NAME" ${URL} > /dev/null 2>&1; } || { wget -U "Mozilla/5.0" ${URL} -O "$TMPDIR/$ACTUAL_ZIP_NAME" > /dev/null 2>&1 || exit 1;}
        aria2c -x16 -j$(nproc) -U "Mozilla/5.0" -d "$TMPDIR" -o "$ACTUAL_ZIP_NAME" ${URL} > /dev/null 2>&1 || {
            wget -U "Mozilla/5.0" ${URL} -O "$TMPDIR/$ACTUAL_ZIP_NAME" > /dev/null 2>&1 || exit 1
        }
    fi
}

LEAVE() {
    rm -rf "$TARGETDIR" "$TMPDIR" "$LOCALDIR/SGSI" "$IMAGESDIR" 
}

if ! [ $image == true ];then
    if [[ "$URL" == "http"* ]]; then
        # URL detected
        ACTUAL_ZIP_NAME=update.zip
        ZIP_NAME="$LOCALDIR"/tmp/update.zip
        DOWNLOAD "$URL" "$ZIP_NAME"
        URL="$ZIP_NAME"
        echo "├─ Downloaded."
    fi

#Extract firmware
 "$LOCALDIR"/make.sh $build $URL || { echo "> Failed to extract!" ; exit  1 ; }

#SGSI Time
cd $LOCALDIR
if [ -e $IMAGESDIR/system.img ];then
  echo "┠⌬ Porting SGSI..."
  "$LOCALDIR"/SGSI.sh $build $TYPE || { echo "> Failed to complete SGSI patching!" ; exit  1 ; }
else
  echo "> System image not found!"
  exit 1
fi
fi

#Build image
 "$LOCALDIR"/makeimg.sh $build $NAME || { echo "> Failed to build image!" ; exit 1 ; }

if [ -d "$OUTDIR" ]; then
   cd $OUTDIR
   cp -fr Build*txt README.txt > /dev/null 2>&1 || { echo "> SGSI not found!" ; exit 1 ; }
   LEAVE
   echo "┠⌬─ Ported SGSI137!"
else
   echo "> SGSI failed!"
   exit 1
fi
