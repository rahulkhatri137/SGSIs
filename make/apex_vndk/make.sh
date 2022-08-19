#!/bin/bash

source ../../bin.sh
systempath=$1
systemdir=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

rm -rf $systempath/apex/*current*
7z x -y $thispath/v31apex.7z -o$systempath/apex/ 2>/dev/null >> $systempath/zip.log
7z x -y $thispath/v32apex.7z -o$systempath/apex/ 2>/dev/null >> $systempath/zip.log
7z x -y $thispath/13apex.7z -o$systempath/apex/ 2>/dev/null >> $systempath/zip.log
# Add apex to system
7z x -y $thispath/v28apex.7z -o$systempath/apex/ 2>/dev/null >> $systempath/zip.log
7z x -y $thispath/v29apex.7z -o$systempath/apex/ 2>/dev/null >> $systempath/zip.log
7z x -y $thispath/v30apex.7z -o$systempath/apex/ 2>/dev/null >> $systempath/zip.log
rm -rf $systempath/zip.log
cd $bin/apex_tools
./apex_extractor.sh "$TARGETDIR" "$systempath/apex" > /dev/null 2>&1
cd $LOCALDIR

# Clean up default apex state
sed -i '/ro.apex.updatable/d' $systemdir/build.prop
sed -i '/ro.apex.updatable/d' $systemdir/product/etc/build.prop
sed -i '/ro.apex.updatable/d' $systemdir/system_ext/etc/build.prop

apex_flatten() {
  # Force using flatten apex
  echo "" >> $systemdir/product/etc/build.prop
  echo "# Apex state" >> $systemdir/product/etc/build.prop
  echo "ro.apex.updatable=false" >> $systemdir/product/etc/build.prop

  # Cleanup apex
  apex_files=$(ls $systemdir/apex | grep ".apex$")
  for apex in $apex_files ;do
    if [ -f $systemdir/apex/$apex ];then
     rm -rf $systemdir/apex/$apex
    fi
  done
  # Not mount apex setup
  [ -f $systemdir/etc/init/apex-sharedlibs.rc ] && rm -rf $systemdir/etc/init/apex-sharedlibs.rc
}

apex_enable() {
  # Force enable apex
  echo "" >> $systemdir/product/etc/build.prop
  echo "# Apex state" >> $systemdir/product/etc/build.prop
  echo "ro.apex.updatable=true" >> $systemdir/product/etc/build.prop
  
  apex_dirs=$(find $systemdir/apex -maxdepth 1 -type d | grep -v "$systemdir/apex$")
  for apex_dir in $apex_dirs;do
    if [ -d $apex_dir ];then
      rm -rf $apex_dir
    fi
  done
}

if [ $(cat $TARGETDIR/apex_state) = true ];then
  apex_enable
elif [ $(cat $TARGETDIR/apex_state) = false ];then
  apex_flatten
fi

rm -rf $systemdir/system_ext/apex
# Create vndk symlinks
rm -rf $systemdir/lib/vndk-29 $systemdir/lib/vndk-sp-29
rm -rf $systemdir/lib/vndk-28 $systemdir/lib/vndk-sp-28
rm -rf $systemdir/lib/vndk-30 $systemdir/lib/vndk-sp-30
rm -rf $systemdir/lib64/vndk-29 $systemdir/lib64/vndk-sp-29
rm -rf $systemdir/lib64/vndk-28 $systemdir/lib64/vndk-sp-28
rm -rf $systemdir/lib64/vndk-30 $systemdir/lib64/vndk-sp-30
rm -rf $systemdir/lib/vndk-31 $systemdir/lib/vndk-sp-31
rm -rf $systemdir/lib64/vndk-31 $systemdir/lib64/vndk-sp-31
rm -rf $systemdir/lib/vndk-32 $systemdir/lib/vndk-sp-32
rm -rf $systemdir/lib64/vndk-32 $systemdir/lib64/vndk-sp-32

ln -s  /apex/com.android.vndk.v29/lib $systemdir/lib/vndk-29
ln -s  /apex/com.android.vndk.v28/lib $systemdir/lib/vndk-28
ln -s  /apex/com.android.vndk.v30/lib $systemdir/lib/vndk-30
ln -s  /apex/com.android.vndk.v29/lib $systemdir/lib/vndk-sp-29
ln -s  /apex/com.android.vndk.v28/lib $systemdir/lib/vndk-sp-28
ln -s  /apex/com.android.vndk.v30/lib $systemdir/lib/vndk-sp-30
ln -s  /apex/com.android.vndk.v31/lib $systemdir/lib/vndk-31
ln -s  /apex/com.android.vndk.v31/lib $systemdir/lib/vndk-sp-31
ln -s  /apex/com.android.vndk.v32/lib $systemdir/lib/vndk-32
ln -s  /apex/com.android.vndk.v32/lib $systemdir/lib/vndk-sp-32

ln -s  /apex/com.android.vndk.v29/lib64 $systemdir/lib64/vndk-29
ln -s  /apex/com.android.vndk.v28/lib64 $systemdir/lib64/vndk-28
ln -s  /apex/com.android.vndk.v30/lib64 $systemdir/lib64/vndk-30
ln -s  /apex/com.android.vndk.v29/lib64 $systemdir/lib64/vndk-sp-29
ln -s  /apex/com.android.vndk.v28/lib64 $systemdir/lib64/vndk-sp-28
ln -s  /apex/com.android.vndk.v30/lib64 $systemdir/lib64/vndk-sp-30
ln -s  /apex/com.android.vndk.v31/lib64 $systemdir/lib64/vndk-31
ln -s  /apex/com.android.vndk.v31/lib64 $systemdir/lib64/vndk-sp-31
ln -s  /apex/com.android.vndk.v32/lib64 $systemdir/lib64/vndk-32
ln -s  /apex/com.android.vndk.v32/lib64 $systemdir/lib64/vndk-sp-32
