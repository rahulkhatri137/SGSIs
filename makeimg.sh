#!/bin/bash

# Copyright (C) 2020 Xiaoxindada <2245062854@qq.com>

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/bin.sh
source $TOOLDIR/language_helper.sh

Usage() {
cat <<EOT
Usage:
$0 <os_repackage_type>
  os_repackage_type: System.img repack type: [AB|ab or A|a]
  
  [AB_CONFIG|ab_config]: Use fs_config to repack ab system.img
  [A_CONFIG|a_config]: Use fs_config to repack a-only system.img
EOT
}

os_repackage_type=$1
name=$2
mkdir -p $OUTDIR
case $os_repackage_type in
  "A"|"a"|"A_CONFIG"|"a_config")
    systemdir="$TARGETDIR/system/system"
    system="$systemdir"
    ;;
  "AB"|"ab"|"AB_CONFIG"|"ab_config")  
    systemdir="$TARGETDIR/system"
    system="$systemdir/system"
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

configdir="$TARGETDIR/config"
target_contexts="system_test_contexts"

case $os_repackage_type in
  "A_CONFIG"|"a_config")
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
  "A"|"a"|"AB"|"ab"|"AB_CONFIG"|"ab_config")
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
  echo $SYSTEMDIR_NF
  exit
fi

# Merge FS DATA
cd $MAKEDIR
./add_apex_fs.sh > /dev/null 2>&1 || { echo "> Failed to add apex contexts!" ; exit 1; }
./add_repack_fs.sh > /dev/null 2>&1 || { echo "> Failed to add repack contexts!" ; exit 1; }

cd $LOCALDIR
# Codename
codename=$(grep -oP "(?<=^ro.product.vendor.device=).*" -hs "$TARGETDIR/vendor/build.prop" | head -1)
[[ -z "${codename}" ]] && codename=$(grep -oP "(?<=^ro.product.system.device=).*" -hs $system/build.prop | head -1)
[[ -z "${codename}" ]] && codename=$(grep -oP "(?<=^ro.product.device=).*" -hs $system/build.prop | head -1)
[[ -z "${codename}" ]] && codename=Generic

#Out Variable
date=`date +%Y%m%d`
outputname="$name-13-$date-$codename-SGSI137"
ioutputname="$name-AB-13-$date-$codename-SGSI137"
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

cd $LOCALDIR
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
case $os_repackage_type in
  "A"|"a")
    $bin/mkuserimg_mke2fs.sh "$systemdir" "$output" "ext4" "/system" $size -j "0" -T "1230768000" -L "system" -I "256" -M "/system" -m "0" $configdir/$target_contexts > /dev/null 2>&1
    ;;
  "AB"|"ab")
    $bin/mkuserimg_mke2fs.sh "$systemdir" "$output" "ext4" "/" $size -j "0" -T "1230768000" -L "/" -I "256" -M "/" -m "0" $configdir/$target_contexts
    ;;
  "A_CONFIG"|"a_config")
    $bin/mkuserimg_mke2fs.sh "$systemdir" "$output" "ext4" "/system" $size -j "0" -T "1230768000" -C "$configdir/system_A_fs" -L "system" -I "256" -M "/system" -m "0" "$configdir/system_A_contexts" > /dev/null 2>&1
    ;;
  "AB_CONFIG"|"ab_config")
    $bin/mkuserimg_mke2fs.sh "$systemdir" "$output" "ext4" "/system" $size -j "0" -T "1230768000" -C "$configdir/system_fs_config" -L "system" -I "256" -M "/system" -m "0" "$configdir/system_file_contexts"
    ;;
esac

if [ -s $output ];then
  echo "├⌬ $name ━ $(bytesToHuman $size)" 
else
  rm -rf $OUTDIR 
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
  $SCRIPTDIR/get_build_info.sh "$TARGETDIR" "$output"  > $OUTDIR/$outputtextname
  rm -rf $TARGETDIR/build.prop
  chmod -R 777 $LOCALDIR/output
fi
