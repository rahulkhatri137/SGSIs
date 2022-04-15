#!/bin/bash

# Copyright (C) 2020 Xiaoxindada <2245062854@qq.com>

LOCALDIR=`cd "$( dirname $0 )" && pwd`
cd $LOCALDIR
source ./bin.sh

systemdir="$LOCALDIR/out/system/system"
configdir="$LOCALDIR/out/config"

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
os_type=$2

ver=$(cat $systemdir/build.prop | grep "ro.build.version.sdk" | head -n 1 | cut -d "=" -f 2)
if [ "$ver" == "30" ]; then
    echo "Detected Android11"  > /dev/null 2>&1
else
    echo "> This branch is only to build Android 11!"
    exit 1
fi

function normal() {
 echo "┠ Patching..."
  # 为所有rom修改ramdisk层面的system
  cd ./make/ab_boot
  ./ab_boot.sh > /dev/null 2>&1 
  cd $LOCALDIR

  # 为所有rom启用apex扁平化处理
  rm -rf ./make/apex
  apex_ls() {
    cd $systemdir/apex
    ls
    cd $LOCALDIR
  }
echo "├─ Adding vndk apex..."
  apex_file() {
    apex_ls | grep -q '.apex'
  }
  if apex_file ;then
    ./make/apex_flat/apex.sh "official" > /dev/null 2>&1 
 fi

  # 如果原包不支持apex封装，则添加 *.apex 
  if ! apex_file ;then
    7z x ./make/add_apexs/apex_common.7z -o$systemdir/apex/ > /dev/null 2>&1
    android_art_debug_check() {
      apex_ls | grep -q "art.debug" 
    }
    android_art_release_check() {
      apex_ls | grep -q "art.release"
    }
    if android_art_debug_check ;then
      7z x ./make/add_apexs/art.debug.7z -o$systemdir/apex/ > /dev/null 2>&1
    fi

    if android_art_release_check ;then
      7z x ./make/add_apexs/art.release.7z -o$systemdir/apex/ > /dev/null 2>&1
    fi
  fi

  # apex_vndk调用处理
  cd ./make/apex_vndk_start
  ./make.sh > /dev/null 2>&1 
  cd $LOCALDIR 
 
#Drop vndks
if ! [ "$os_type" == "Generic" ] && ! [ "$os_type" == "Pixel" ]; then
rm -rf $systemdir/apex/*28*
rm -rf $systemdir/apex/*29*
rm -rf $systemdir/system_ext/apex/*28*
rm -rf $systemdir/system_ext/apex/*29*
fi

  # apex_fs数据整合
  cd ./make/apex_flat
  ./add_apex_fs.sh > /dev/null 2>&1 
  cd $LOCALDIR

  # 重置make目录
  true > ./make/add_etc_vintf_patch/manifest_custom
  echo "" >> ./make/add_etc_vintf_patch/manifest_custom
  echo "<!-- oem自定义接口 -->" >> ./make/add_etc_vintf_patch/manifest_custom

  true > ./make/add_build/add_oem_build
  echo "" >> ./make/add_build/add_oem_build
  echo "# oem厂商自定义属性" >> ./make/add_build/add_oem_build
 
Patch SELinux to ensure maximum device compatibility
  sed -i "/typetransition location_app/d" $systemdir/etc/selinux/plat_sepolicy.cil
  sed -i '/software.version/d'  $systemdir/etc/selinux/plat_property_contexts
  sed -i "/ro.build.fingerprint/d" $systemdir/etc/selinux/plat_property_contexts
  
  $SCRIPTDIR/sepolicy_prop_remover.sh "$systemdir/etc/selinux/plat_property_contexts" "device/qcom/sepolicy" > "$systemdir/etc/selinux/plat_property_contexts.tmp"
  mv -f "$systemdir/etc/selinux/plat_property_contexts.tmp" "$systemdir/etc/selinux/plat_property_contexts"

  if [ -e $systemdir/product/etc/selinux/mapping ];then
    find $systemdir/product/etc/selinux/mapping/ -type f -empty | xargs rm -rf
    sed -i '/software.version/d'  $systemdir/product/etc/selinux/product_property_contexts
    sed -i '/miui.reverse.charge/d' $systemdir/product/etc/selinux/product_property_contexts
    sed -i '/ro.cust.test/d' $systemdir/product/etc/selinux/product_property_contexts

    $SCRIPTDIR/sepolicy_prop_remover.sh "$systemdir/product/etc/selinux/product_property_contexts" "device/qcom/sepolicy" > "$systemdir/product/etc/selinux/product_property_contexts.tmp"
    mv -f "$systemdir/product/etc/selinux/product_property_contexts.tmp" "$systemdir/product/etc/selinux/product_property_contexts"
  fi
 
  if [ -e $systemdir/system_ext/etc/selinux/mapping ];then
    find $systemdir/system_ext/etc/selinux/mapping/ -type f -empty | xargs rm -rf
    sed -i '/software.version/d'  $systemdir/system_ext/etc/selinux/system_ext_property_contexts
    sed -i '/ro.cust.test/d' $systemdir/system_ext/etc/selinux/system_ext_property_contexts
    sed -i '/miui.reverse.charge/d' $systemdir/system_ext/etc/selinux/system_ext_property_contexts
    
    $SCRIPTDIR/sepolicy_prop_remover.sh "$systemdir/system_ext/etc/selinux/system_ext_property_contexts" "device/qcom/sepolicy" > "$systemdir/system_ext/etc/selinux/system_ext_property_contexts.tmp"
    mv -f "$systemdir/system_ext/etc/selinux/system_ext_property_contexts.tmp" "$systemdir/system_ext/etc/selinux/system_ext_property_contexts"
  fi
 
  build_modify() {
  # 为所有qssi原包修复机型数据
    qssi() {
      cat $systemdir/build.prop | grep -qo 'qssi'
    }
    if qssi ;then
      echo "├─ Fixing device props..."
      brand=$(cat ./out/vendor/build.prop | grep 'ro.product.vendor.brand')
      device=$(cat ./out/vendor/build.prop | grep 'ro.product.vendor.device')
      manufacturer=$(cat ./out/vendor/build.prop | grep 'ro.product.vendor.manufacturer')
      model=$(cat ./out/vendor/build.prop | grep 'ro.product.vendor.model')
      mame=$(cat ./out/vendor/build.prop | grep 'ro.product.vendor.name')
  
      sed -i '/ro.product.system./d' $systemdir/build.prop
      echo "" >> $systemdir/build.prop
      echo "# 设备参数" >> $systemdir/build.prop
      echo "$brand" >> $systemdir/build.prop
      echo "$device" >> $systemdir/build.prop
      echo "$manufacturer" >> $systemdir/build.prop
      echo "$model" >> $systemdir/build.prop
      echo "$mame" >> $systemdir/build.prop
      sed -i 's/ro.product.vendor./ro.product.system./g' $systemdir/build.prop
    fi

    # 为所有rom改用自适应apex更新支持状态
    sed -i '/ro.apex.updatable/d' $systemdir/build.prop
    sed -i '/ro.apex.updatable/d' $systemdir/product/build.prop
    sed -i '/ro.apex.updatable/d' $systemdir/system_ext/build.prop
 
    # 为所有rom改用分辨率自适应
    sed -i 's/ro.sf.lcd/#&/' $systemdir/build.prop
    sed -i 's/ro.sf.lcd/#&/' $systemdir/product/build.prop
    sed -i 's/ro.sf.lcd/#&/' $systemdir/system_ext/build.prop
   
    # 为所有rom启用CDM电话的系统属性
    sed -i '/telephony.lteOnCdmaDevice/d' $systemdir/build.prop
    sed -i '/telephony.lteOnCdmaDevice/d' $systemdir/product/build.prop
    sed -i '/telephony.lteOnCdmaDevice/d' $systemdir/system_ext/build.prop
    echo "" >> $systemdir/build.prop   
    echo "# System prop to turn on CdmaLTEPhone always" >> $systemdir/build.prop
    echo "telephony.lteOnCdmaDevice=1" >> $systemdir/build.prop
    echo "" >> $systemdir/product/build.prop
    echo "# System prop to turn on CdmaLTEPhone always" >> $systemdir/product/build.prop
    echo "telephony.lteOnCdmaDevice=1" >> $systemdir/product/build.prop
    echo "" >> $systemdir/system_ext/build.prop
    echo "# System prop to turn on CdmaLTEPhone always" >> $systemdir/system_ext/build.prop
    echo "telephony.lteOnCdmaDevice=1" >> $systemdir/system_ext/build.prop       
  
  # Partial Devices Sim fix
    sed -i '/persist.sys.fflag.override.settings\_provider\_model\=/d' $systemdir/build.prop
    sed -i '/persist.sys.fflag.override.settings\_provider\_model\=/d' $systemdir/system_ext/build.prop
    sed -i '/persist.sys.fflag.override.settings\_provider\_model\=/d' $systemdir/product/build.prop
    echo "" >> $systemdir/product/build.prop
    echo "# Partial ROM sim fix" >> $systemdir/product/build.prop
    echo "persist.sys.fflag.override.settings_provider_model=false" >> $systemdir/product/build.prop

    # 为所有rom清理一些无用属性
    sed -i '/vendor.display/d' $systemdir/build.prop
    sed -i '/vendor.perf/d' $systemdir/build.prop
    sed -i '/debug.sf/d' $systemdir/build.prop
    sed -i '/persist.sar.mode/d' $systemdir/build.prop
    sed -i '/opengles.version/d' $systemdir/build.prop

    # 为所有rom禁用product vndk version
    sed -i '/product.vndk.version/d' $systemdir/product/build.prop

    # 为所有rom禁用caf media.setting
    sed -i '/media.settings.xml/d' $systemdir/build.prop

    # 为所有rom添加必要的通用属性
    sed -i '/system_root_image/d' $systemdir/build.prop
    sed -i '/ro.control_privapp_permissions/d' $systemdir/build.prop
    sed -i '/ro.control_privapp_permissions/d' $systemdir/product/build.prop
    sed -i '/ro.control_privapp_permissions/d' $systemdir/system_ext/build.prop  
    cat ./make/add_build/add_build >> $systemdir/build.prop
    cat ./make/add_build/add_product_build >> $systemdir/product/build.prop
    cat ./make/add_build/add_system_ext_build >> $systemdir/system_ext/build.prop

    # 为所有rom启用虚拟建
    mainkeys() {
      grep -q 'qemu.hw.mainkeys=' $systemdir/build.prop
    }  
    if mainkeys ;then
      sed -i 's/qemu.hw.mainkeys\=1/qemu.hw.mainkeys\=0/g' $systemdir/build.prop
    else
      echo "" >> $systemdir/build.prop
      echo "# 启用虚拟键" >> $systemdir/build.prop
      echo "qemu.hw.mainkeys=0" >> $systemdir/build.prop
    fi

    # 为所有qssi原包修改默认设备参数读取
    source_order() {
      grep -q 'ro.product.property_source_order=' $systemdir/build.prop
    }
    if source_order ;then
      sed -i '/ro.product.property\_source\_order\=/d' $systemdir/build.prop  
      echo "" >> $systemdir/build.prop
      echo "# 机型专有设备参数默认读取顺序" >> $systemdir/build.prop
      echo "ro.product.property_source_order=system,product,system_ext,vendor,odm" >> $systemdir/build.prop
    fi

    # Clean devices custom properites
    clean_custom_prop() {
      $SCRIPTDIR/clean_properites.sh "$systemdir/build.prop" "/system.prop" > "$systemdir/build.prop.tmp"
      mv -f "$systemdir/build.prop.tmp" "$systemdir/build.prop"
      $SCRIPTDIR/clean_properites.sh "$systemdir/system_ext/build.prop" "/system_ext.prop" > "$systemdir/system_ext/build.prop.tmp"
      mv -f "$systemdir/system_ext/build.prop.tmp" "$systemdir/system_ext/build.prop"
      $SCRIPTDIR/clean_properites.sh "$systemdir/product/build.prop" "/product.prop" > "$systemdir/product/build.prop.tmp"
      mv -f "$systemdir/product/build.prop.tmp" "$systemdir/product/etc/build.prop"
    }

    # Default clean custom prop
    clean_prop=false
    [ $os_type = "Generic" ] && clean_prop=true
    [ $clean_prop = true ] && clean_custom_prop
  }
  build_modify

  # 为所有rom还原fstab.postinstall
  find  ./out/system/ -type f -name "fstab.postinstall" | xargs rm -rf
  sed -i '/fstab\\.postinstall/d' $configdir/system_file_contexts
  sed -i '/fstab.postinstall/d' $configdir/system_fs_config
  
  # 添加缺少的libs
  cp -frpn ./make/add_libs/system/* $systemdir
 
  # 为default启用debug调试
  sed -i 's/persist.sys.usb.config=none/persist.sys.usb.config=adb/g' $systemdir/etc/prop.default
  sed -i 's/ro.debuggable=0/ro.debuggable=1/g' $systemdir/etc/prop.default
  sed -i 's/ro.adb.secure=1/ro.adb.secure=0/g' $systemdir/etc/prop.default
  echo "ro.force.debuggable=1" >> $systemdir/etc/prop.default
 
  # 为default修补oem的SurfaceFlinger属性
  if [ -e ./out/vendor/default.prop ];then
    rm -rf ./default.txt
    cat ./out/vendor/default.prop | grep 'surface_flinger' > ./default.txt
  fi
  default="$(find $systemdir -type f -name 'prop.default')"
  if [ ! $default = "" ];then
    if [ -e ./default.txt ];then
      surface_flinger() {
        default="$(find $systemdir -type f -name 'prop.default')"
        cat $default | grep -q 'surface_flinger'
      }
      if surface_flinger ;then
        rm -rf ./default.txt
      else
        echo "" >> $default
        cat ./default.txt >> $default
        rm -rf ./default.txt
      fi
    fi
  fi

  # 为所有rom删除qti_permissions
  find $systemdir -type f -name "qti_permissions.xml" | xargs rm -rf

  # 为所有rom删除firmware
  find $systemdir -type d -name "firmware" | xargs rm -rf

  # 为所有rom删除avb
  find $systemdir -type d -name "avb" | xargs rm -rf
  
  # 为所有rom删除com.qualcomm.location
  find $systemdir -type d -name "com.qualcomm.location" | xargs rm -rf

  # 为所有rom删除多余文件
  rm -rf ./out/system/verity_key
  rm -rf ./out/system/init.recovery*
  rm -rf $systemdir/recovery-from-boot.*

  # 为所有rom patch system
  cp -frp ./make/system_patch/system/* $systemdir/

  # 为所有rom做phh化处理
  cp -frp ./make/add_phh/system/* $systemdir/

  cp -frp ./make/resign/system/* $systemdir/
   $MAKEDIR/resign/generate_fs.sh > /dev/null 2>&1 || { echo "> Failed to patch overlays" && exit 1; }

  # 为添加的文件注册必要的selinux上下文
  cat ./make/add_plat_file_contexts/plat_file_contexts >> $systemdir/etc/selinux/plat_file_contexts
  cat ./make/add_plat_file_contexts/phh_plat_file_contexts >> $systemdir/etc/selinux/plat_file_contexts

  # 为所有rom的相机修改为aosp相机
  #cd ./make/camera
  #./camera.sh
  cd $LOCALDIR

  # Rom specific patch
echo "├─ Fixing ROM..."
./apps_clean/pixel.sh "$systemdir" > /dev/null 2>&1 
  cd ./make
  ./romtype.sh "$os_type" > /dev/null 2>&1 || { echo "> Failed to to patch rom" ; exit 1; }
  cd $LOCALDIR 

  # oem_build合并
  cat ./make/add_build/add_oem_build >> $systemdir/build.prop

 # Change Build Number
if [[ $(grep "ro.build.display.id" $systemdir/build.prop) ]]; then
    displayid="ro.build.display.id"
elif [[ $(grep "ro.system.build.id" $systemdir/build.prop) ]]; then
    displayid="ro.system.build.id"
elif [[ $(grep "ro.build.id" $systemdir/build.prop) ]]; then
    displayid="ro.build.id"
fi
displayid2=$(echo "$displayid" | sed 's/\./\\./g')
bdisplay=$(grep "$displayid" $systemdir/build.prop | sed 's/\./\\./g; s:/:\\/:g; s/\,/\\,/g; s/\ /\\ /g')
sed -i "s/$bdisplay/$displayid2=Ported\.by\.RK137/" $systemdir/build.prop

  # 为rom添加oem服务所依赖的hal接口
  rm -rf ./vintf
  mkdir ./vintf
  cp -frp $systemdir/etc/vintf/manifest.xml ./vintf/
  manifest="./vintf/manifest.xml"
  sed -i '/<\/manifest>/d' $manifest
  cat ./make/add_etc_vintf_patch/manifest_common >> $manifest
  cat ./make/add_etc_vintf_patch/manifest_custom >> $manifest
  echo "" >> $manifest
  echo "</manifest>" >> $manifest
  cp -frp $manifest $systemdir/etc/vintf/
  rm -rf ./vintf
  
  # fs数据整合
  cat ./make/add_fs/vndk_symlink_contexts >> $configdir/system_file_contexts
  cat ./make/add_fs/vndk_symlink_fs >> $configdir/system_fs_config  
  cat ./make/add_fs/bin_contexts >> $configdir/system_file_contexts 
  cat ./make/add_fs/bin_fs >> $configdir/system_fs_config 
  cat ./make/add_fs/etc_contexts >> $configdir/system_file_contexts 
  cat ./make/add_fs/etc_fs >> $configdir/system_fs_config 
  cat ./make/add_phh/contexts >> $configdir/system_file_contexts
  cat ./make/add_phh/fs >> $configdir/system_fs_config
  rm -rf ./make/lib_fs
  mkdir ./make/lib_fs

  lib_fs="$LOCALDIR/make/lib_fs/fs"
  lib_contexts="$LOCALDIR/make/lib_fs/contexts"
 
  rm -rf $lib_fs
  rm -rf $lib_contexts
  sed -i '/\/system\/system\/lib\//d' $configdir/system_file_contexts
  sed -i '/system\/system\/lib\//d' $configdir/system_fs_config
  sed -i '/\/system\/system\/lib64\//d' $configdir/system_file_contexts
  sed -i '/system\/system\/lib64\//d' $configdir/system_fs_config
  
  cd $systemdir/lib
  libs=$(find ./ -name "*")
  for lib in $libs ;do
    if [ -d "$lib" ];then
      echo "$lib" | sed 's#\./#/#g' | sed 's/^/&system\/system\/lib/g' | sed 's/$/& 0 0 0755/g' >> $lib_fs
      echo "$lib" | sed 's#\./#/#g' | sed 's/^/&\/system\/system\/lib/g' | sed 's/$/& u:object_r:system_lib_file:s0/g' >> $lib_contexts
    fi

    if [ -L "$lib" ];then
      echo "$lib" | sed 's#\./#/#g' | sed 's/^/&system\/system\/lib/g' | sed 's/$/& 0 0 0644/g' >> $lib_fs
      echo "$lib" | sed 's#\./#/#g' | sed 's/^/&\/system\/system\/lib/g' | sed 's/$/& u:object_r:system_lib_file:s0/g' >> $lib_contexts
    fi 

    if [ -f "$lib" ];then
      echo "$lib" | sed 's#\./#/#g' | sed 's/^/&system\/system\/lib/g' | sed 's/$/& 0 0 0644/g' >> $lib_fs
      echo "$lib" | sed 's#\./#/#g' | sed 's/^/&\/system\/system\/lib/g' | sed 's/$/& u:object_r:system_lib_file:s0/g' >> $lib_contexts
    fi 
  done
  cd $LOCALDIR

  cd $systemdir/lib64
  libs=$(find ./ -name "*")
  for lib in $libs ;do
    if [ -d "$lib" ];then
      echo "$lib" | sed 's#\./#/#g' | sed 's/^/&system\/system\/lib64/g' | sed 's/$/& 0 0 0755/g' >> $lib_fs
      echo "$lib" | sed 's#\./#/#g' | sed 's/^/&\/system\/system\/lib64/g' | sed 's/$/& u:object_r:system_lib_file:s0/g' >> $lib_contexts
    fi

    if [ -L "$lib" ];then
      echo "$lib" | sed 's#\./#/#g' | sed 's/^/&system\/system\/lib64/g' | sed 's/$/& 0 0 0644/g' >> $lib_fs
      echo "$lib" | sed 's#\./#/#g' | sed 's/^/&\/system\/system\/lib64/g' | sed 's/$/& u:object_r:system_lib_file:s0/g' >> $lib_contexts
    fi 

    if [ -f "$lib" ];then
      echo "$lib" | sed 's#\./#/#g' | sed 's/^/&system\/system\/lib64/g' | sed 's/$/& 0 0 0644/g' >> $lib_fs
      echo "$lib" | sed 's#\./#/#g' | sed 's/^/&\/system\/system\/lib64/g' | sed 's/$/& u:object_r:system_lib_file:s0/g' >> $lib_contexts
    fi 
  done
  cd $LOCALDIR
  sed -i '1d' $lib_fs
  sed -i '1d' $lib_contexts
  cat $lib_contexts >> $configdir/system_file_contexts
  cat $lib_fs >> $configdir/system_fs_config
}

 function fix_bug() {
    echo "┠ Fixing Bugs..."
    cd fixbug
    ./fixbug.sh "$os_type" > /dev/null 2>&1 || { echo "> Failed to fixbug!" ; exit 1; }
    cd $LOCALDIR
}

function resign() {
echo "┠ Resigning with AOSP keys..."
      python $bin/tools/signapk/resign.py "$systemdir" "$bin/tools/signapk/AOSP_security" "$bin/$HOST/$platform/lib64" > $TARGETDIR/resign.log 2> $TOOLDIR/other/resign.log || { echo "> Failed to resign!" ; exit 1; }
echo "├─ Resigned."
}

rm -rf $TOOLDIR/other/resign.log $TOOLDIR/other/img.log

normal
echo "├─ Patched."
fix_bug
if [ "$os_type" == "Generic" ] || [ "$os_type" == "Pixel" ]; then
    resign
fi
rm -rf $TOOLDIR/other/resign.log
echo "┠⌬─ SGSI Processed."
exit 0
