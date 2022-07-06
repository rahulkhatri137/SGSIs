#!/bin/bash

# Copyright (C) 2021 Xiaoxindada <2245062854@qq.com>

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/bin.sh

Usage() {
cat <<EOT
Usage:
$0 <Build Type> <Firmware Path>
  Build Type: [AB|ab] or [A|a]
  Firmware Path: Rom Firmware Path
EOT
}

case $1 in 
  "AB"|"ab")
    build_type="AB"
    ;;
  "A"|"a")
    build_type="A"
    echo "- A-only SGSI not supported"
    exit 1
    ;;
  "-h"|"--help")
    Usage
    exit 1
    ;;    
  *)
    Usage
    exit 1
    ;;
esac

if [ $# -lt 2 ];then
  Usage
  exit 1
fi
firmware=$2
systemdir=$TARGETDIR/system/system
configdir="$TARGETDIR/config"

if [ ! -e $firmware ];then
  if [ ! -e $TMPDIR/$firmware ];then
    echo "- Firmware not found!"
    exit 1
  fi  
fi

function firmware_extract() { 
cd $LOCALDIR
rm -rf $IMAGESDIR $TARGETDIR
  if [ -e $firmware ];then
    ./Firmware_extractor/extractor.sh $firmware $TMPDIR  > /dev/null 2>&1 || { echo "> Failed to extract firmware" && exit 1; }
  fi
  if [ -e $TMPDIR/$firmware ];then
       ./Firmware_extractor/extractor.sh "$TMPDIR/$firmware" "$TMPDIR/" > /dev/null 2>&1 || { echo "> Failed to extract firmware" && exit 1; }
  fi
}

chmod -R 777 ./
./workspace_cleanup.sh > /dev/null 2>&1

if [[ $firmware == system.img ]]; then
rm -rf $TARGETDIR
mkdir -p $IMAGESDIR
mv $firmware $IMAGESDIR/
else
echo "┠ Extracting Firmware..."
firmware_extract
fi

mkdir -p $IMAGESDIR
mkdir -p $TARGETDIR
mkdir -p $OUTDIR

# Detect image
 if [[ -d $TMPDIR ]];then
 cd $TMPDIR
 mv *.img $IMAGESDIR/
fi

cd $LOCALDIR
echo "├─ Extracting images..."
# Sparse Image To Raw Image
$SCRIPTDIR/simg2img.sh "$IMAGESDIR" > /dev/null 2>&1 || { echo "> Failed to convert sparse image!" ; exit 1; }

# Extract Image
$SCRIPTDIR/image_extract.sh > /dev/null 2>&1 || { echo "> Failed to extract image!" ; exit 1; }
echo "├─ Extracted."
if [[ -d $systemdir/../system_ext && -L $systemdir/system_ext ]] \
|| [[ -d $systemdir/../product && -L $systemdir/product ]];then
  echo "┠ Merging dynamic partitions..."
  $SCRIPTDIR/partition_merge.sh > /dev/null 2>&1 || { echo "> Failed to merge dynamic partitions!" ; exit 1; }
  echo "├─ Merged."
fi

exit 0
