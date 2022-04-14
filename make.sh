#!/bin/bash

# Copyright (C) 2020 Xiaoxindada <2245062854@qq.com>

LOCALDIR=`cd "$( dirname $0 )" && pwd`
cd $LOCALDIR
source ./bin.sh

Usage() {
cat <<EOT
Usage:
$0 AB|ab or $0 A|a
EOT
}
firmware=$1
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
chown -R root:root ./
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
./image_extract.sh > /dev/null 2>&1 || { echo "> Failed to extract image!" ; exit 1; }
echo "├─ Extracted."
if [[ -d $systemdir/../system_ext && -L $systemdir/system_ext ]] \
|| [[ -d $systemdir/../product && -L $systemdir/product ]];then
  echo "┠ Merging dynamic partitions..."
  $SCRIPTDIR/partition_merge.sh > /dev/null 2>&1 || { echo "> Failed to merge dynamic partitions!" ; exit 1; }
  echo "├─ Merged."
fi

exit 0
