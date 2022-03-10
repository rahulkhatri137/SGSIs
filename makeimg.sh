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

case $1 in 
  "AB"|"ab"|"A"|"a")
    echo "" > /dev/null 2>&1
    ;;
  *)
    Usage
    exit
    ;;
esac

system_type=$1
case $system_type in
  "AB"|"ab")
    systemdir="$LOCALDIR/out/system"
    system="$LOCALDIR/out/system/system"
    ;;
  "A"|"a")
    systemdir="$LOCALDIR/out/system/system"
    ;;
  *)
    echo "error!"
    exit
    ;;    
esac
name=$2
mkdir -p output
case $system_type in
  "A"|"a")
    echo "/ u:object_r:system_file:s0" > ./out/config/system_A_contexts
    echo "/system u:object_r:system_file:s0" >> ./out/config/system_A_contexts
    echo "/system(/.*)? u:object_r:system_file:s0" >> ./out/config/system_A_contexts
    echo "/system/lost+found u:object_r:system_file:s0" >> ./out/config/system_A_contexts

    echo "/ 0 0 0755" > ./out/config/system_A_fs
    echo "system 0 0 0755" >> ./out/config/system_A_fs
    echo "system/lost+found 0 0 0700" >> ./out/config/system_A_fs

    cat ./out/config/system_file_contexts | grep "system_ext" >> ./out/config/system_ext_contexts
    cat ./out/config/system_fs_config | grep "system_ext" >> ./out/config/system_ext_fs
    cat ./out/config/system_file_contexts | grep "/system/system/" >> ./out/config/system_A_contexts
    cat ./out/config/system_fs_config | grep "system/system/" >> ./out/config/system_A_fs

    sed -i 's#/system/system/system_ext#/system/system_ext#' ./out/config/system_ext_contexts
    sed -i 's#system/system/system_ext#system/system_ext#' ./out/config/system_ext_fs
    sed -i 's#/system/system#/system#' ./out/config/system_A_contexts
    sed -i 's#system/system#system#' ./out/config/system_A_fs

    cat ./out/config/system_ext_contexts >> ./out/config/system_A_contexts
    cat ./out/config/system_ext_fs >> ./out/config/system_A_fs
  ;;
esac  

if [ ! -d $systemdir ];then
  echo "system目录不存在！"
  exit
fi


cd $LOCALDIR
# Codename
codename=$(grep -oP "(?<=^ro.product.vendor.device=).*" -hs "$TARGETDIR/vendor/build.prop" | head -1)
[[ -z "${codename}" ]] && codename=$(grep -oP "(?<=^ro.product.system.device=).*" -hs $system/build.prop | head -1)
[[ -z "${codename}" ]] && codename=$(grep -oP "(?<=^ro.product.device=).*" -hs $system/build.prop | head -1)
[[ -z "${codename}" ]] && codename=Generic

#Out Variable
date=`date +%Y%m%d`
outputname="$name-11-$date-$codename-SGSI137"
ioutputname="$name-AB-11-$date-$codename-SGSI137"
outputimagename="$ioutputname".img
outputtextname="Build-info-$outputname".txt
output="$OUTDIR/$outputimagename"

#Overlays
outputvendoroverlaysname="VendorOverlays-$outputname".tar.gz
outputvendoroverlays="$OUTDIR/$outputvendoroverlaysname"
if [[ -d "$TARGETDIR/vendor/overlay" && ! -f "$outputvendoroverlays" ]]; then
        mkdir -p "$OUTDIR/vendorOverlays"
        cp -frp $TARGETDIR/vendor/overlay/* "$OUTDIR/vendorOverlays" >> /dev/null 2>&1
 if [ -d "$OUTDIR/vendorOverlays" ]; then
        cd $OUTDIR/vendorOverlays
        echo "├─ Extracting VOverlays..."
        tar -zcvf "$outputvendoroverlays" * >> /dev/null 2>&1
        cd $LOCALDIR
        rm -rf "output/vendorOverlays"
 fi
fi

size=`du -sk $systemdir | awk '{$1*=1024;$1=int($1*1.05);printf $1}'`
bytesToHuman() {
    b=${1:-0}; d=''; s=0; S=(Bytes {K,M,G,T,P,E,Z,Y}iB)
    while ((b > 1024)); do
        d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
        b=$((b / 1024))
        let s++
    done
    echo "$b$d ${S[$s]}"
}

echo "┠⌬ Packing Image..."
case $system_type in
  "A"|"a")
    $bin/mkuserimg_mke2fs.sh "$systemdir" "./out/system.img" "ext4" "/system" $size -j "0" -T "1230768000" -C "./out/config/system_A_fs" -L "system" -I "256" -M "/system" -m "0" "./out/config/system_A_contexts"
    ;;
  "AB"|"ab")
    $bin/mkuserimg_mke2fs.sh "$systemdir" "$output" "ext4" "/system" $size -j "0" -T "1230768000" -C "./out/config/system_fs_config" -L "system" -I "256" -M "/system" -m "0" "./out/config/system_file_contexts"
    ;;
esac

if [ -s $output ];then
  echo "├⌬ $name($codename) ━ $(bytesToHuman $size)" 
else
  rm -rf output 
  exit 1
fi

echo "├─ Generating SGSI info..."
#System Tree
outputtreename="System-Tree-$outputname".txt
outputtree="$OUTDIR/$outputtreename"
if [ ! -f "$outputtree" ]; then
    tree $systemdir >> "$outputtree" 2> "$outputtree"
fi

if [ -s $output ];then
  rm -rf $TMPDIR
  cp -frp $system/build.prop $TARGETDIR/
  $SCRIPTDIR/get_build_info.sh "$TARGETDIR" "$output" > $OUTDIR/$outputtextname
  rm -rf $TARGETDIR/build.prop
  chmod -R 777 $LOCALDIR/output
fi
