#!/bin/bash

# Copyright (C) 2021 Xiaoxindada <2245062854@qq.com>

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/bin.sh
source $TOOLDIR/language_helper.sh

Usage() {
cat <<EOT
Usage:
$0 <Build Type> <OS Type> [Other args]
  Build Type: [AB|ab] or [A|a]
  OS Type: Rom OS type to build

  Other args:
    [--fix-bug]: Fix bugs in ROM
EOT
}

case $1 in
  "AB"|"ab")
    build_type="AB"
    ;;
  "A"|"a")
    build_type="A"
    echo "$NOTSUPPAONLY"
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

os_type="$2"
build_type="$build_type"
other_args=""
systemdir="$TARGETDIR/system/system"
configdir="$TARGETDIR/config"
shift 2

ver=$(cat $systemdir/build.prop | grep "ro.build.version.sdk" | head -n 1 | cut -d "=" -f 2)
if [ "$ver" == "31" ] || [ "$ver" == "32" ]; then
    echo "Detected Android12" > /dev/null 2>&1
else
    echo "> This branch is only to build Android 12!"
    exit 1
fi
function normal() {
  # Process ramdisk's system for all rom
  echo "-> $PROCESSING_RAMDISK_SYSTEM" > /dev/null 2>&1
  ramdisk_modify() {
    rm -rf "$systemdir/../persist"
    rm -rf "$systemdir/../bt_firmware"
    rm -rf "$systemdir/../firmware"
    rm -rf "$systemdir/../cache"
    mkdir -p "$systemdir/../persist"
    mkdir -p "$systemdir/../cache"
    ln -s "/vendor/bt_firmware" "$systemdir/../bt_firmware"
    ln -s "/vendor/firmware" "$systemdir/../firmware"

    if [ -f $configdir/system_file_contexts ];then
      sed -i '/\/system\/persist /d' $configdir/system_file_contexts
      sed -i '/\/system\/bt_firmware /d' $configdir/system_file_contexts
      sed -i '/\/system\/firmware /d' $configdir/system_file_contexts
      sed -i '/\/system\/cache /d' $configdir/system_file_contexts

      echo "/system/persist u:object_r:mnt_vendor_file:s0" >> $configdir/system_file_contexts
      echo "/system/bt_firmware u:object_r:bt_firmware_file:s0" >> $configdir/system_file_contexts
      echo "/system/firmware u:object_r:firmware_file:s0" >> $configdir/system_file_contexts
      echo "/system/cache u:object_r:cache_file:s0" >> $configdir/system_file_contexts
    fi

    if [ -f $configdir/system_fs_config ];then
      sed -i '/system\/persist /d' $configdir/system_fs_config
      sed -i '/system\/bt_firmware /d' $configdir/system_fs_config
      sed -i '/system\/firmware /d' $configdir/system_fs_config
      sed -i '/system\/cache /d' $configdir/system_fs_config

      echo "system/persist 0 0 0755" >> $configdir/system_fs_config
      echo "system/bt_firmware 0 0 0644" >> $configdir/system_fs_config
      echo "system/firmware 0 0 0644" >> $configdir/system_fs_config
      echo "system/cache 1000 2001 0770" >> $configdir/system_fs_config
    fi
  }
  ramdisk_modify
  echo "-> $PROCESS_SUCCESS" > /dev/null 2>&1

  cd $LOCALDIR 
  echo "-> $OTHER_PROCESSINGS" > /dev/null 2>&1

  # Reset manifest_custom
  true > $MAKEDIR/add_etc_vintf_patch/manifest_custom
  echo "" >> $MAKEDIR/add_etc_vintf_patch/manifest_custom
  echo "<!-- oem hal -->" >> $MAKEDIR/add_etc_vintf_patch/manifest_custom

  true > $MAKEDIR/add_build/oem_prop
  echo "" >> $MAKEDIR/add_build/oem_prop
  echo "# oem common prop" >> $MAKEDIR/add_build/oem_prop

  # Patch SELinux to ensure maximum device compatibility
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
  # Fix Device Properties for qssi
    qssi() {
      cat $systemdir/build.prop | grep -qo 'qssi'
    }
    if qssi ;then
      echo "├─ Fixing device props..."
      brand=$(cat $TARGETDIR/vendor/build.prop | grep 'ro.product.vendor.brand')
      device=$(cat $TARGETDIR/vendor/build.prop | grep 'ro.product.vendor.device')
      manufacturer=$(cat $TARGETDIR/vendor/build.prop | grep 'ro.product.vendor.manufacturer')
      model=$(cat $TARGETDIR/vendor/build.prop | grep 'ro.product.vendor.model')
      mame=$(cat $TARGETDIR/vendor/build.prop | grep 'ro.product.vendor.name')

      sed -i '/ro.product.system./d' $systemdir/build.prop
      echo "" >> $systemdir/build.prop
      echo "# Device Settings" >> $systemdir/build.prop
      echo "$brand" >> $systemdir/build.prop
      echo "$device" >> $systemdir/build.prop
      echo "$manufacturer" >> $systemdir/build.prop
      echo "$model" >> $systemdir/build.prop
      echo "$mame" >> $systemdir/build.prop
      sed -i 's/ro.product.vendor./ro.product.system./g' $systemdir/build.prop
    fi
 
    # Enable auto-adapting dpi
    sed -i 's/ro.sf.lcd/#&/' $systemdir/build.prop
    sed -i 's/ro.sf.lcd/#&/' $systemdir/product/etc/build.prop
    sed -i 's/ro.sf.lcd/#&/' $systemdir/system_ext/etc/build.prop    
  
    # Cleanup properties
    sed -i '/vendor.display/d' $systemdir/build.prop
    sed -i '/vendor.perf/d' $systemdir/build.prop
    sed -i '/debug.sf/d' $systemdir/build.prop
    sed -i '/debug.sf/d' $systemdir/product/etc/build.prop
    sed -i '/ro.sys.sdcardfs/d' $systemdir/product/etc/build.prop
    sed -i '/persist.sar.mode/d' $systemdir/build.prop
    sed -i '/opengles.version/d' $systemdir/build.prop
    sed -i '/actionable_compatible_property.enabled/d' $systemdir/build.prop

    # Disable caf media.setting
    sed -i '/media.settings.xml/d' $systemdir/build.prop

    # Add common properties
    sed -i '/system_root_image/d' $systemdir/build.prop
    sed -i '/ro.control_privapp_permissions/d' $systemdir/build.prop
    sed -i '/ro.control_privapp_permissions/d' $systemdir/product/etc/build.prop
    sed -i '/ro.control_privapp_permissions/d' $systemdir/system_ext/etc/build.prop  
    cat $MAKEDIR/add_build/system_prop >> $systemdir/build.prop
    cat $MAKEDIR/add_build/product_prop >> $systemdir/product/etc/build.prop
    cat $MAKEDIR/add_build/system_ext_prop >> $systemdir/system_ext/etc/build.prop

    # Enable HW Mainkeys
    mainkeys() {
      grep -q 'qemu.hw.mainkeys=' $systemdir/build.prop
    }  
    if mainkeys ;then
      sed -i 's/qemu.hw.mainkeys\=1/qemu.hw.mainkeys\=0/g' $systemdir/build.prop
    else
      echo "" >> $systemdir/build.prop
      echo "# Enable HW Mainkeys" >> $systemdir/build.prop
      echo "qemu.hw.mainkeys=0" >> $systemdir/build.prop
    fi

    # Hack qssi property read order
    source_order() {
      grep -q 'ro.product.property_source_order=' $systemdir/build.prop
    }
    if source_order ;then
      sed -i '/ro.product.property\_source\_order\=/d' $systemdir/build.prop
      echo "" >> $systemdir/build.prop
      echo "# Property Read Order" >> $systemdir/build.prop
      echo "ro.product.property_source_order=system,product,system_ext,vendor,odm" >> $systemdir/build.prop
    fi

    # Clean devices custom properites
    clean_custom_prop() {
      $SCRIPTDIR/clean_properites.sh "$systemdir/build.prop" "/system.prop" > "$systemdir/build.prop.tmp"
      mv -f "$systemdir/build.prop.tmp" "$systemdir/build.prop"
      $SCRIPTDIR/clean_properites.sh "$systemdir/system_ext/etc/build.prop" "/system_ext.prop" > "$systemdir/system_ext/etc/build.prop.tmp"
      mv -f "$systemdir/system_ext/etc/build.prop.tmp" "$systemdir/system_ext/etc/build.prop"
      $SCRIPTDIR/clean_properites.sh "$systemdir/product/etc/build.prop" "/product.prop" > "$systemdir/product/etc/build.prop.tmp"
      mv -f "$systemdir/product/etc/build.prop.tmp" "$systemdir/product/etc/build.prop"
    }

    # Default clean custom prop
    clean_prop=false
    [ $os_type = "Generic" ] && clean_prop=true
    [ $clean_prop = true ] && clean_custom_prop
  }
  build_modify

  # Diable reboot_on_failure Check
  sed -i "/reboot_on_failure/d" $systemdir/etc/init/hw/init.rc
  sed -i "/reboot_on_failure/d" $systemdir/etc/init/apexd.rc

  # Revert fstab.postinstall to gsi state
  find $systemdir/../ -type f -name "fstab.postinstall" | xargs rm -rf
  rm -rf $systemdir/etc/init/cppreopts.rc    
  sed -i '/fstab\\.postinstall/d' $configdir/system_file_contexts
  sed -i '/fstab.postinstall/d' $configdir/system_fs_config
  
echo "┠ Patching..."
  # Add missing libs
  cp -frpn $MAKEDIR/add_libs/system/* $systemdir
 
  # Enable debug feature
  sed -i 's/persist.sys.usb.config=none/persist.sys.usb.config=adb/g' $systemdir/build.prop
  sed -i 's/ro.debuggable=0/ro.debuggable=1/g' $systemdir/build.prop
  sed -i 's/ro.adb.secure=1/ro.adb.secure=0/g' $systemdir/build.prop
  
  sed -i 's/persist.sys.usb.config=none/persist.sys.usb.config=adb/g' $systemdir/system_ext/etc/build.prop
  sed -i 's/ro.debuggable=0/ro.debuggable=1/g' $systemdir/system_ext/etc/build.prop
  sed -i 's/ro.adb.secure=1/ro.adb.secure=0/g' $systemdir/system_ext/etc/build.prop

  sed -i 's/persist.sys.usb.config=none/persist.sys.usb.config=adb/g' $systemdir/product/etc/build.prop
  sed -i 's/ro.debuggable=0/ro.debuggable=1/g' $systemdir/product/etc/build.prop
  sed -i 's/ro.adb.secure=1/ro.adb.secure=0/g' $systemdir/product/etc/build.prop
  echo "" >> $systemdir/product/etc/build.prop
  echo "# force debug" >> $systemdir/product/etc/build.prop
  echo "ro.force.debuggable=1" >> $systemdir/product/etc/build.prop

  # Remove qti_permissions
  find $systemdir -type f -name "qti_permissions.xml" | xargs rm -rf

  # Remove firmware
  find $systemdir -type d -name "firmware" | xargs rm -rf

  # Remove avb
  find $systemdir -type d -name "avb" | xargs rm -rf
  
  # Remove com.qualcomm.location
  find $systemdir -type d -name "com.qualcomm.location" | xargs rm -rf

  # Remove some useless files
  rm -rf $systemdir/../verity_key
  rm -rf $systemdir/../init.recovery*
  rm -rf $systemdir/recovery-from-boot.*

  # Patch System
  cp -frp $MAKEDIR/system_patch/system/* $systemdir/

  # Patch system to phh system
  cp -frp $MAKEDIR/add_phh/system/* $systemdir/

  # Register selinux contexts related by phh system
  cat $MAKEDIR/add_plat_file_contexts/phh_plat_file_contexts >> $systemdir/etc/selinux/plat_file_contexts

  # Register selinux contexts related by added files
  cat $MAKEDIR/add_plat_file_contexts/plat_file_contexts >> $systemdir/etc/selinux/plat_file_contexts

  # Replace to AOSP Camera
  #cd $MAKEDIR/camera
  #./camera.sh > /dev/null 2>&1
  #cd $LOCALDIR

  # Default flatten apex
if [ "$os_type" == "Generic" ]; then
  echo "false" > $TARGETDIR/apex_state
else
  echo "true" > $TARGETDIR/apex_state
fi

echo "├─ $FIXING_ROM"
  # Rom specific patch
  cd $MAKEDIR
  $DEBLOATDIR/pixel.sh "$systemdir" > /dev/null 2>&1 
  ./romtype.sh "$os_type" > /dev/null 2>&1 || { echo "> Failed to to patch rom" ; exit 1; }
  cd $LOCALDIR

# Common apex process
echo "├─ Adding vndk apex..."
cd $MAKEDIR/apex_vndk
./make.sh $systemdir || { echo "> Failed to add vndk apex" ; exit 1; }

# Partial Devices Sim fix
    sed -i '/persist.sys.fflag.override.settings\_provider\_model\=/d' $systemdir/build.prop
    sed -i '/persist.sys.fflag.override.settings\_provider\_model\=/d' $systemdir/system_ext/etc/build.prop
    sed -i '/persist.sys.fflag.override.settings\_provider\_model\=/d' $systemdir/product/etc/build.prop
    echo "" >> $systemdir/product/etc/build.prop
    echo "# Partial ROM sim fix" >> $systemdir/product/etc/build.prop
    echo "persist.sys.fflag.override.settings_provider_model=false" >> $systemdir/product/etc/build.prop

# Disable bpfloader
    rm -rf $systemdir/etc/init/bpfloader.rc
    echo ""  >> $systemdir/product/etc/build.prop
    echo "# Disable bpfloader" >> $systemdir/product/etc/build.prop
    echo "bpf.progs_loaded=1" >> $systemdir/product/etc/build.prop

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

  # Add oem_build
  cat $MAKEDIR/add_build/oem_prop >> $systemdir/build.prop

  # Add OEM HAL Manifest Interfaces
  manifest_tmp="$TARGETDIR/vintf/manifest.xml"
  rm -rf $(dirname $manifest_tmp)
  mkdir -p $(dirname $manifest_tmp)
  cp -frp $systemdir/etc/vintf/manifest.xml $(dirname $manifest_tmp)
  sed -i '/<\/manifest>/d' $manifest_tmp
  cat $MAKEDIR/add_etc_vintf_patch/manifest_common >> $manifest_tmp
  cat $MAKEDIR/add_etc_vintf_patch/manifest_custom >> $manifest_tmp
  echo "" >> $manifest_tmp
  echo "</manifest>" >> $manifest_tmp
  cp -frp $manifest_tmp $systemdir/etc/vintf/
  rm -rf $(dirname $manifest_tmp)
  cp -frp $MAKEDIR/add_etc_vintf_patch/manifest_custom $TARGETDIR/manifest_custom
  true > $MAKEDIR/add_etc_vintf_patch/manifest_custom
  echo "" >> $MAKEDIR/add_etc_vintf_patch/manifest_custom
  echo "<!-- oem hal -->" >> $MAKEDIR/add_etc_vintf_patch/manifest_custom
}

function fix_bug() {
    echo "┠ $START_BUG_FIX"
    cd $FBDIR
    ./fixbug.sh "$os_type" > /dev/null 2>&1 || { echo "> Failed to fixbug!" ; exit 1; }
    cd $LOCALDIR
}

function resign() {
echo "┠ Resigning with AOSP keys..."
      cp -frp $MAKEDIR/resign/system/* $systemdir/
      $bin/tools/signapk/resign.py "$systemdir" "$bin/tools/signapk/AOSP_security" "$bin/$HOST/$platform/lib64" > $TARGETDIR/resign.log 2> $TOOLDIR/other/resign.log || { echo "> Failed to resign!" ; exit 1; }
}

if (echo $@ | grep -qo -- "--fix-bug") ;then
  other_args+=" --fix-bug"
fi

rm -rf ./SGSI
cd $LOCALDIR

normal
echo "├─ Patched."
if (echo $other_args | grep -qo -- "--fix-bug") ;then
    fix_bug
fi

rm -rf $TOOLDIR/other/resign.log $TOOLDIR/other/img.log
if [ "$os_type" == "Generic" ] || [ "$os_type" == "Pixel" ]; then
    resign
fi
echo "├─ Resigned."
rm -rf $TOOLDIR/other/resign.log
cd $LOCALDIR
# Format output
for i in $(ls $configdir);do
if [ -f $configdir/$i ];then
sort -u $configdir/$i > $configdir/${i}-tmp
mv -f $configdir/${i}-tmp $configdir/$i
sed -i '/^\s*$/d' $configdir/$i
fi
done
echo "┠⌬─ SGSI Processed."
exit 0
