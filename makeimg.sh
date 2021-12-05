#!/bin/bash

# Copyright (C) 2020 Xiaoxindada <2245062854@qq.com>

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source ./bin.sh
source ./language_helper.sh

Usage() {
cat <<EOT
Usage:
$0 <os_repackage_type>
  os_repackage_type: System.img repack type: [--AB|--ab or -A|--a-only]
  
  [--AB_CONFIG|--ab_config]: Use fs_config to repack ab system.img
  [--A-ONLY_CONFIG|--a-only_config]: Use fs_config to repack a-only system.img
EOT
}

os_repackage_type="$1"

case $os_repackage_type in
  "-A"|"-a"|"--a-only"|"--A-ONLY_CONFIG"|"--a-only_config")
    systemdir="$TARGETDIR/system/system"
    ;;
  "--AB"|"--ab"|"--AB_CONFIG"|"--ab_config")  
    systemdir="$TARGETDIR/system"
    ;;
  "-h"|"--help")
    Usage
    exit
    ;;
  *)
    Usage
    exit
    ;;
esac

if [ "$1" = "" ];then
  Usage
  exit
fi

configdir="$TARGETDIR/config"
target_contexts="system_test_contexts"

case $os_repackage_type in
  "--AB"|"--ab"|"--AB_CONFIG"|"--ab_config")
    system="$systemdir/system"
    ;;
  "-A"|"--a-only"|"--A-ONLY_CONFIG"|"--a-only_config")
    system="$systemdir"
    ;;    
esac

case $os_repackage_type in
  "--A-ONLY_CONFIG"|"--a-only_config")
    echo "/ u:object_r:system_file:s0" > $configdir/system_A_contexts
    echo "/system u:object_r:system_file:s0" >> $configdir/system_A_contexts
    echo "/system(/.*)? u:object_r:system_file:s0" >> $configdir/system_A_contexts
    echo "/system/lost+found u:object_r:system_file:s0" >> $configdir/system_A_contexts

    echo "/ 0 0 0755" > $configdir/system_A_fs
    echo "system 0 0 0755" >> $configdir/system_A_fs
    echo "system/lost+found 0 0 0700" >> $configdir/system_A_fs

    cat $configdir/system_file_contexts | grep "system_ext" >> $configdir/system_ext_contexts
    cat $configdir/system_fs_config | grep "system_ext" >> $configdir/system_ext_fs
    cat $configdir/system_file_contexts | grep "/system/system/" >> $configdir/system_A_contexts
    cat $configdir/system_fs_config | grep "system/system/" >> $configdir/system_A_fs

    sed -i 's#/system/system/system_ext#/system/system_ext#' $configdir/system_ext_contexts
    sed -i 's#system/system/system_ext#system/system_ext#' $configdir/system_ext_fs
    sed -i 's#/system/system#/system#' $configdir/system_A_contexts
    sed -i 's#system/system#system#' $configdir/system_A_fs

    cat $configdir/system_ext_contexts >> $configdir/system_A_contexts
    cat $configdir/system_ext_fs >> $configdir/system_A_fs
    ;;
esac

# Generate debloated file_contexts
file_contexts() {
  rm -rf $configdir/$target_contexts
  mkdir -p $configdir

  cat $system/etc/selinux/plat_file_contexts >> $configdir/$target_contexts

  partition_name="system_ext product vendor"
  for partition in $partition_name ;do
    if [ -d $systemdir/$partition/etc/selinux ];then 
      file_contexts=$(ls $system/$partition/etc/selinux | grep file_contexts*)
      #echo $system/$partition/etc/selinux/$file_contexts
      [ -z $(cat $system/$partition/etc/selinux/$file_contexts) ] && continue
      cat $system/$partition/etc/selinux/$file_contexts >> $configdir/$target_contexts
    fi
  done
}
file_contexts

case $os_repackage_type in
  "-A"|"--a-only"|"--AB"|"--ab"|"--AB_CONFIG"|"--ab_config")
    if [[ -f $configdir/$target_contexts ]]; then
      echo "/firmware(/.*)?         u:object_r:firmware_file:s0" >> $configdir/$target_contexts
      echo "/bt_firmware(/.*)?      u:object_r:bt_firmware_file:s0" >> $configdir/$target_contexts
      echo "/persist(/.*)?          u:object_r:mnt_vendor_file:s0" >> $configdir/$target_contexts
      echo "/dsp                    u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/oem                    u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/op1                    u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/op2                    u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/charger_log            u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/audit_filter_table     u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/keydata                u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/keyrefuge              u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/omr                    u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/publiccert.pem         u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/sepolicy_version       u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/cust                   u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/donuts_key             u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/v_key                  u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/carrier                u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/dqmdbg                 u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/ADF                    u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/APD                    u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/asdf                   u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/batinfo                u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/voucher                u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/xrom                   u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/custom                 u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/cpefs                  u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/modem                  u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/module_hashes          u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/pds                    u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/tombstones             u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/factory                u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/oneplus(/.*)?          u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/addon.d                u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/op_odm                 u:object_r:rootfs:s0" >> $configdir/$target_contexts
      echo "/avb                    u:object_r:rootfs:s0" >> $configdir/$target_contexts
    fi
    ;;
esac

if [ ! -d $systemdir ];then
  echo "$SYSTEMDIR_NF" > /dev/null 2>&1
  exit
fi

# Codename
codename=$(grep -oP "(?<=^ro.product.vendor.device=).*" -hs "$TARGETDIR/vendor/build.prop" | head -1)
[[ -z "${codename}" ]] && codename=$(grep -oP "(?<=^ro.product.system.device=).*" -hs $system/build.prop | head -1)
[[ -z "${codename}" ]] && codename=$(grep -oP "(?<=^ro.product.device=).*" -hs $system/build.prop | head -1)
[[ -z "${codename}" ]] && codename=Generic

#Out Variable
date=`date +%Y%m%d`
outputname="$NAME-12-$date-$codename-RK137SGSI"
ioutputname="$NAME-AB-12-$date-$codename-RK137SGSI"
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
        echo "-> Extracting Vendor Overlays..."
        tar -zcvf "$outputvendoroverlays" "$OUTDIR/vendorOverlays" >> /dev/null 2>&1
        rm -rf "output/vendorOverlays"
 fi
fi

echo "
$CURR_IMG_SIZE:
_________________

`du -sh $systemdir | awk '{print $1}' | bc -q | sed 's/$/&G/'`

`du -sm $systemdir | awk '{print $1}' | bc -q | sed 's/$/&M/'`

`du -sk $systemdir | awk '{print $1}' | bc -q | sed 's/$/&B/'`
_________________
" > /dev/null 2>&1
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

echo "-> Packing Image..."
#mke2fs+e2fsdroid 打包
#$bin/mke2fs -L / -t ext4 -b 4096 $TARGETDIR/system.img $size
#$bin/e2fsdroid -e -T 0 -S $configdir/system_file_contexts -C $configdir/system_fs_config  -a /system -f ./out/system $TARGETDIR/system.img

case $os_repackage_type in
  "-A"|"-a"|"--a-only")
    $bin/mkuserimg_mke2fs.sh "$systemdir" "$TARGETDIR/system.img" "ext4" "/system" $size -j "0" -T "1230768000" -L "system" -I "256" -M "/system" -m "0" $configdir/$target_contexts > /dev/null 2>&1
    ;;
  "--AB"|"--ab")
    $bin/mkuserimg_mke2fs.sh "$systemdir" "$TARGETDIR/system.img" "ext4" "/" $size -j "0" -T "1230768000" -L "/" -I "256" -M "/" -m "0" $configdir/$target_contexts > /dev/null 2>&1
    ;;
  "--A-ONLY_CONFIG"|"--a-only_config")
    $bin/mkuserimg_mke2fs.sh "$systemdir" "$TARGETDIR/system.img" "ext4" "/system" $size -j "0" -T "1230768000" -C "$configdir/system_A_fs" -L "system" -I "256" -M "/system" -m "0" "$configdir/system_A_contexts" > /dev/null 2>&1
    ;;
  "--AB_CONFIG"|"--ab_config")
    $bin/mkuserimg_mke2fs.sh "$systemdir" "$TARGETDIR/system.img" "ext4" "/system" $size -j "0" -T "1230768000" -C "$configdir/system_fs_config" -L "system" -I "256" -M "/system" -m "0" "$configdir/system_file_contexts" > /dev/null 2>&1
    ;;
esac

if [ -s $TARGETDIR/system.img ];then
  echo "-> Created $outputname | Size: $(bytesToHuman $size)" 
  echo "$OUTPUTTO_STR: $LOCALDIR/output" > /dev/null 2>&1
else
  echo "-> SGSI image not found! Exiting... "
  exit 1
fi

#System Tree
outputtreename="System-Tree-$outputname".txt
outputtree="$OUTDIR/$outputtreename"
if [ ! -f "$outputtree" ]; then
    tree $systemdir >> "$outputtree" 2> "$outputtree"
fi

if [ -s $TARGETDIR/system.img ];then
  rm -rf $LOCALDIR/tmp
  mv -f $TARGETDIR/system.img $output
  cp -frp $system/build.prop $TARGETDIR/
  $SCRIPTDIR/get_build_info.sh "$TARGETDIR" "$output"  > $OUTDIR/$outputtextname
  rm -rf $TARGETDIR/build.prop
  chmod -R 777 $LOCALDIR/output
fi
