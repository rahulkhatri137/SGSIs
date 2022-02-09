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

mkdir -p ./tmp
chmod -R 777 ./
chown -R root:root ./
rm -rf ./*.img
./workspace_cleanup.sh > /dev/null 2>&1
zip=$1

echo "-> Extracting firmware..."
if [ -e $zip ] || [ -e ./tmp/$zip ];then
  if [ -e ./tmp/$zip ];then
    7z x "./tmp/$zip" -o"./tmp/" > /dev/null 2>&1
  else 
    7z x "$zip" -o"./tmp/" > /dev/null 2>&1
  fi
else
  echo "> Firmware not found!"
  exit 1
fi

cd ./tmp
# payload.bin检测
if [ -e './payload.bin' ];then
  mv ./payload.bin ../payload
  echo "-> Unpacking payload..."
  cd ../payload
  python2 ./payload.py ./payload.bin ./out > /dev/null 2>&1
  mv ./payload.bin ../tmp
  if [ -e "./out/product.img" ];then
    mv ./out/product.img ../tmp/
  fi
 
  if [ -e "./out/system_ext.img" ];then
    mv ./out/system_ext.img ../tmp/
  fi

  if [ -e "./out/reserve.img" ];then
    mv ./out/reserve.img ../tmp/
  fi

  if [ -e "./out/odm.img" ];then
    mv ./out/odm.img ../tmp/
  fi  
 
  if [ -e "./out/boot.img" ];then
    mv ./out/boot.img ../tmp/
  fi  
  
  if [ -e "./out/vendor_boot.img" ];then
    mv ./out/vendor_boot.img ../tmp/
  fi  
  mv ./out/system.img ../tmp/
  mv ./out/vendor.img ../tmp/
  rm -rf ./out/*
  cd ../tmp
  mv ./system.img ../
  mv ./vendor.img ../

  if [ -e "./product.img" ];then
    mv ./product.img ../
  fi

  if [ -e "./system_ext.img" ];then
    mv ./system_ext.img ../
  fi
 
  if [ -e "./reserve.img" ];then
    mv ./reserve.img ../
  fi
  
  if [ -e "./odm.img" ];then
    mv ./odm.img ../
  fi    

  if [ -e "./boot.img" ];then
    mv ./boot.img ../
  fi
  
  if [ -e "./vendor_boot.img" ];then
    mv ./vendor_boot.img ../
  fi  
fi

# br检测
if [ -e ./system.new.dat.br ];then
   $bin/brotli -d system.new.dat.br > /dev/null 2>&1
   python $bin/sdat2img.py system.transfer.list system.new.dat ./system.img > /dev/null 2>&1
   mv ./system.img ../
   rm -rf ./system.new.dat

  if [ -e ./vendor.new.dat.br ];then
    $bin/brotli -d vendor.new.dat.br > /dev/null 2>&1
    python $bin/sdat2img.py vendor.transfer.list vendor.new.dat ./vendor.img > /dev/null 2>&1
    mv ./vendor.img ../
    rm -rf ./vendor.new.dat 
  fi

  if [ -e ./product.new.dat.br ];then
    $bin/brotli -d product.new.dat.br > /dev/null 2>&1
    python $bin/sdat2img.py product.transfer.list product.new.dat ./product.img > /dev/null 2>&1
    mv ./product.img ../
    rm -rf ./product.new.dat
  fi

  if [ -e ./system_ext.new.dat.br ];then
    $bin/brotli -d system_ext.new.dat.br > /dev/null 2>&1
    python $bin/sdat2img.py system_ext.transfer.list system_ext.new.dat ./system_ext.img > /dev/null 2>&1
    mv ./system_ext.img ../
    rm -rf ./system_ext.new.dat
  fi

  if [ -e ./odm.new.dat.br ];then
    $bin/brotli -d odm.new.dat.br > /dev/null 2>&1
    python $bin/sdat2img.py odm.transfer.list odm.new.dat ./odm.img > /dev/null 2>&1
    mv ./odm.img ../
    rm -rf ./odm.new.dat
  fi
fi

# dat检测
if [ -e ./system.new.dat.1 ];then
  if [ -e ./system.new.dat.1 ];then
    cat ./system.new.dat.{1..999} 2>/dev/null >> ./system.new.dat
    rm -rf ./system.new.dat.{1..999}
    python $bin/sdat2img.py system.transfer.list system.new.dat ./system.img > /dev/null 2>&1
    mv ./system.img ../
  fi

  if [ -e ./vendor.new.dat.1 ];then
    cat ./vendor.new.dat.{1..999} 2>/dev/null >> ./vendor.new.dat
    rm -rf ./vendor.new.dat.{1..999}
    python $bin/sdat2img.py vendor.transfer.list vendor.new.dat ./vendor.img > /dev/null 2>&1
    mv ./vendor.img ../
  fi

  if [ -e ./product.new.dat.1 ];then
    cat ./product.new.dat.{1..999} 2>/dev/null >> ./product.new.dat
    rm -rf ./product.new.dat.{1..999}
    python $bin/sdat2img.py product.transfer.list product.new.dat ./product.img > /dev/null 2>&1
    mv ./product.img ../
  fi

  if [ -e ./system_ext.new.dat.1 ];then
    cat ./system_ext.new.dat.{1..999} 2>/dev/null >> ./system_ext.new.dat
    rm -rf ./product.new.dat.{1..999}
    python $bin/sdat2img.py system_ext.transfer.list system_ext.new.dat ./system_ext.img > /dev/null 2>&1
    mv ./system_ext.img ../
  fi  

  if [ -e ./odm.new.dat.1 ];then
    cat ./odm.new.dat.{1..999} 2>/dev/null >> ./odm.new.dat
    rm -rf ./odm.new.dat.{1..999}
    python $bin/sdat2img.py odm.transfer.list odm.new.dat ./odm.img > /dev/null 2>&1
    mv ./odm.img ../
  fi    
else
  if [ -e ./system.new.dat ];then
    python $bin/sdat2img.py system.transfer.list system.new.dat ./system.img > /dev/null 2>&1
    mv ./system.img ../
  fi
  
  if [ -e ./vendor.new.dat ];then
    python $bin/sdat2img.py vendor.transfer.list vendor.new.dat ./vendor.img > /dev/null 2>&1
    mv ./vendor.img ../
  fi

  if [ -e ./product.new.dat ];then
    python $bin/sdat2img.py product.transfer.list product.new.dat ./product.img > /dev/null 2>&1
    mv ./product.img ../
  fi
 
  if [ -e ./system_ext.new.dat ];then
    python $bin/sdat2img.py system_ext.transfer.list system_ext.new.dat ./system_ext.img > /dev/null 2>&1
    mv ./system_ext.img ../
  fi

 if [ -e ./odm.new.dat ];then
   python $bin/sdat2img.py odm.transfer.list odm.new.dat ./odm.img > /dev/null 2>&1
   mv ./odm.img ../
  fi
fi

echo "- Extracted."
if [ -e ./system.img ];then
  mv ./*.img ../
fi
exit 0