#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR

prop_dir="$1"
image_file="$2"
bytesToHuman() {
    b=${1:-0}; d=''; s=0; S=(Bytes {K,M,G,T,P,E,Z,Y}iB)
    while ((b > 1024)); do
        d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
        b=$((b / 1024))
        let s++
    done
    echo "$b$d ${S[$s]}"
}
device_manufacturer=$(cat $prop_dir/build.prop | grep "ro.product.system.manufacture" | head -n 1 | cut -d "=" -f 2)
android_version=$(cat $prop_dir/build.prop | grep "ro.build.version.release" | head -n 1 | cut -d "=" -f 2)
android_code_name=$(cat $prop_dir/build.prop | grep "ro.build.version.codename" | head -n 1 | cut -d "=" -f 2)
device_product=$(cat $prop_dir/build.prop | grep "ro.build.product=" | head -n 1 | cut -d "=" -f 2)
android_sdk=$(cat $prop_dir/build.prop | grep "ro.build.version.sdk" | head -n 1 | cut -d "=" -f 2)
andriod_spl=$(cat $prop_dir/build.prop | grep "ro.build.version.security_patch" | head -n 1 | cut -d "=" -f 2)
device_model=$(cat $prop_dir/build.prop | grep "ro.product.system.model" | head -n 1 | cut -d "=" -f 2)
description_info=$(cat $prop_dir/build.prop | grep "ro.build.description" | head -n 1 | cut -d "=" -f 2)
android_fingerprint=$(cat $prop_dir/build.prop | grep "ro.system.build.fingerprint" | head -n 1 | cut -d "=" -f 2)
android_image_name=$(echo ${image_file##*/})
android_image_size=`du -sk $image_file | awk '{$1*=1024;$1=int($1*1.05);printf $1}'`
build_date=$(date +%Y-%m-%d-%H:%M)

echo "
Android Version: $android_version
Brand: $device_manufacturer
Model: $device_model
Codename: $device_product
Security Patch: $andriod_spl
Fingerprint: $android_fingerprint
Description: $description_info
Raw Image Size: $(bytesToHuman $android_image_size)
"
