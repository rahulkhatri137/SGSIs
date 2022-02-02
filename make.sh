#!/bin/bash

# Copyright (C) 2021 Xiaoxindada <2245062854@qq.com>
#		2021 Jiuyu <2652609017@qq.com>

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR
source $LOCALDIR/bin.sh
source $TOOLDIR/language_helper.sh

Usage() {
cat <<EOT
Usage:
$0 <Build Type> <OS Type> <Firmware Path> [Other args]
  Build Type: [AB|ab] or [A|a]
  OS Type: Rom OS type to build
  Firmware Path: Rom Firmware Path

  Other args:
    [--fix-bug]: Fix bugs in Rom
EOT
}

case $1 in 
  "AB"|"ab")
    build_type="AB"
    ;;
  "A"|"a")
    build_type="A"
    echo $NOTSUPPAONLY
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

if [ $# -lt 3 ];then
  Usage
  exit 1
fi
os_type="$2"
firmware="$3"
build_type="$build_type"
shift 3

if ! (cat $MAKEDIR/rom_support_list.txt | grep -qo "$os_type");then
  echo "> Rom type is not supported!"
  echo "Following are the supported types -"
  cat $MAKEDIR/rom_support_list.txt
  exit 1
fi

if [ ! -e $firmware ];then
  if [ ! -e $TMPDIR/$firmware ];then
    echo $NOTFOUNDFW
    exit 1
  fi  
fi

function firmware_extract() {
  partition_list="system vendor system_ext odm product reserve boot vendor_boot"
  
  if [ -e $firmware ];then
    7z x -y "$firmware" -o"$TMPDIR/" > /dev/null 2>&1 || { echo "> Failed to extract firmware!" ; exit 1; }
  fi
  if [ -e $TMPDIR/$firmware ];then
    7z x -y "$TMPDIR/$firmware" -o"$TMPDIR/" > /dev/null 2>&1 || { echo "> Failed to extract firmware" && exit 1; }
  fi

  for i in $(ls $TMPDIR);do
    [ ! -d $TMPDIR/$i ] && continue
    cd $TMPDIR/$i
    if [ $(ls | wc -l) != "0" ];then
      mv -f ./* ../
    fi
    cd $LOCALDIR
  done

  cd $TMPDIR
  for partition in $partition_list ;do
    # Detect payload.bin
    if [ -e ./payload.bin ];then
      mv ./payload.bin ../payload/
      cd ../payload
      echo " -> $UNZIPINGPLB"
      python ./payload.py ./payload.bin ./out || { echo "> Failed to extract payload!" ; exit 1; }
      echo "-> Moving Files to workspace..."
      for i in $partition_list ;do
        if [ -e ./out/$i.img ];then
          mv ./out/$i.img $IMAGESDIR/
        fi
      done
      rm -rf ./payload.bin
      rm -rf ./out/*
      cd $TMPDIR
    fi

    # Detect dat.br
    if [ -e ./${partition}.new.dat.br ];then
      echo "$UNPACKING_STR ${partition}.new.dat.br" > /dev/null 2>&1
      $bin/brotli -d ${partition}.new.dat.br > /dev/null 2>&1 || { echo "> Failed to convert brotli" ; exit 1; }
      python $bin/sdat2img.py ${partition}.transfer.list ${partition}.new.dat ./${partition}.img > /dev/null 2>&1 || { echo "> Failed to convert sdat" ; exit 1; }
      mv ./${partition}.img $IMAGESDIR/
      rm -rf ./${partition}.new.dat
    fi
  
    # Detect split new.dat
    if [ -e ./${partition}.new.dat.1 ];then
      echo "$SPLIT_DETECTED ${partition}.new.dat, $MERGING_STR" > /dev/null 2>&1
      cat ./${partition}.new.dat.{1..999} 2>/dev/null >> ./${partition}.new.dat
      rm -rf ./${partition}.new.dat.{1..999}
      python $bin/sdat2img.py ${partition}.transfer.list ${partition}.new.dat ./${partition}.img > /dev/null 2>&1 || { echo "> Failed to convert sdat" ; exit 1; }
      mv ./${partition}.img $IMAGESDIR/
      rm -rf ./${partition}.new.dat
    fi

    # Detect general new.dat
    if [ -e ./${partition}.new.dat ];then
      echo "$UNPACKING_STR ${partition}.new.dat" > /dev/null 2>&1
      python $bin/sdat2img.py ${partition}.transfer.list ${partition}.new.dat ./${partition}.img > /dev/null 2>&1 || { echo "> Failed to convert sdat" ; exit 1; }
      mv ./${partition}.img $IMAGESDIR/
    fi

    # Detect image
    if [ -e ./${partition}.img ];then
      mv ./${partition}.img $IMAGESDIR/
    fi
  done
}

chmod -R 777 ./
./workspace_cleanup.sh > /dev/null 2>&1
rm -rf $WORKSPACE
mkdir -p $IMAGESDIR
mkdir -p $TARGETDIR
mkdir -p $OUTDIR

echo "-> Extracting Firmware..."
firmware_extract
echo "- Extracted."

cd $LOCALDIR
echo "-> Extracting images..."
# Sparse Image To Raw Image
$SCRIPTDIR/simg2img.sh "$IMAGESDIR" > /dev/null 2>&1 || { echo "> Failed to convert sparse image!" ; exit 1; }

# Mount Partitions
#./scripts/mount_partition.sh > /dev/null 2>&1 || { echo "> Failed to mount!" ; exit 1; }
cd $LOCALDIR

# Extract Image
./image_extract.sh > /dev/null 2>&1 || { echo "> Failed to extract image!" ; exit 1; }
if [[ -d $systemdir/../system_ext && -L $systemdir/system_ext ]] \
|| [[ -d $systemdir/../product && -L $systemdir/product ]];then
  echo "-> Merging dynamic partitions..."
  $SCRIPTDIR/partition_merge.sh > /dev/null 2>&1 || { echo "> Failed to merge dynamic partitions!" ; exit 1; }
fi

if [[ ! -d $systemdir/product ]];then
  echo "$systemdir/product $DIR_NOT_FOUND_STR!"
  exit 1
elif [[ ! -d $systemdir/system_ext ]];then
  echo "$systemdir/system_ext $DIR_NOT_FOUND_STR!"
  exit 1
fi
exit 0
