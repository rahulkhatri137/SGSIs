#!/bin/bash
 
LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/../bin.sh
source $TOOLDIR/language_helper.sh

os_type="$1"
systemdir="$TARGETDIR/system/system"
configdir="$TARGETDIR/config"
rom_folder="$LOCALDIR/rom_make_patch"
vintf_folder="$LOCALDIR/add_etc_vintf_patch"

# pixel
if [ $os_type = "Pixel" ];then
  # Add oem properites
  #./add_build.sh > /dev/null 2>&1
  $vintf_folder/pixel/add_vintf.sh > /dev/null 2>&1
  # Fixing ROM Features
  $rom_folder/pixel/make.sh > /dev/null 2>&1
  echo "$DEBLOATING_STR"
  $DEBLOATDIR/pixel.sh "$systemdir" > /dev/null 2>&1
  # Not flatten apex
  echo "true" > $TARGETDIR/apex_state
fi

# oxygen
if [ $os_type = "OxygenOS" ];then
  ./add_build.sh > /dev/null 2>&1
  $vintf_folder/h2os/add_vintf.sh > /dev/null 2>&1
  # Fixing ROM Features
  $rom_folder/h2os/make.sh > /dev/null 2>&1
  echo "$DEBLOATING_STR"
  $DEBLOATDIR/h2os.sh "$systemdir" > /dev/null 2>&1
fi
 
 # flyme
if [ $os_type = "Flyme" ];then
  ./add_build.sh > /dev/null 2>&1
  $vintf_folder/flyme/add_vintf.sh > /dev/null 2>&1
  echo "$DEBLOATING_STR"
  $DEBLOATDIR/flyme.sh "$systemdir" > /dev/null 2>&1
fi
 
# miui
if [ $os_type = "MIUI" ];then
  ./add_build.sh > /dev/null 2>&1
  .$vintf_folder/miui/add_vintf.sh > /dev/null 2>&1
  # Fixing ROM Features
  $rom_folder/miui/make.sh > /dev/null 2>&1
  echo "$DEBLOATING_STR"
  $DEBLOATDIR/miui.sh "$systemdir" > /dev/null 2>&1
fi
 
# joy
if [ $os_type = "JoyUI" ];then
  cp -frp $(find ../out/vendor -type f -name 'init.blackshark.rc') $systemdir/etc/init/
  cp -frp $(find ../out/vendor -type f -name 'init.blackshark.common.rc') $systemdir/etc/init/
  echo "/system/system/etc/init/init\.blackshark\.common\.rc u:object_r:system_file:s0" >> ../out/config/system_file_contexts
  echo "/system/system/etc/init/init\.blackshark\.rc u:object_r:system_file:s0" >> ../out/config/system_file_contexts   
  sed -i '/^\s*$/d' ../out/config/system_file_contexts
  echo "system/system/etc/init/init.blackshark.common.rc 0 0 0644" >> ../out/config/system_fs_config
  echo "system/system/etc/init/init.blackshark.rc 0 0 0644" >> ../out/config/system_fs_config
  sed -i '/^\s*$/d' ../out/config/system_fs_config
  echo "$DEBLOATING_STR"
  $DEBLOATDIR/miui.sh "$systemdir" > /dev/null 2>&1
fi

# nubia
if [ $os_type = "Nubia" ];then
  $DEBLOATDIR/nubia.sh "$systemdir" > /dev/null 2>&1
fi

# vivo
if [ $os_type = "FuntouchOS" ];then
  ./add_build.sh > /dev/null 2>&1
  $vintf_folder/vivo/add_vintf.sh > /dev/null 2>&1
  # Fixing ROM Features
  $rom_folder/vivo/make.sh > /dev/null 2>&1
  echo "$DEBLOATING_STR"
  $DEBLOATDIR/vivo.sh "$systemdir" > /dev/null 2>&1
fi

# oppo
if [ $os_type = "ColorOS" ];then
  ./add_build.sh > /dev/null 2>&1
  $vintf_folder/add_vintf.sh > /dev/null 2>&1
  # Fixing ROM Features
  $rom_folder/oppo/make.sh > /dev/null 2>&1
  echo "$DEBLOATING_STR"
  $DEBLOATDIR/oppo.sh "$systemdir" > /dev/null 2>&1
fi
