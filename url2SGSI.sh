#!/bin/bash

# Inspired from url2GSI from ErfanGSIs tool at https://github.com/erfanoabdi/ErfanGSIs
# Copyright to Rahul at https://github.com/rahulkhatri137

LOCALDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $LOCALDIR
ver=12
build=AB
fixbug=""
image=""
usage() {
cat <<EOT
Usage:
$0 <Firmware link> <Firmware type>
   Firmware link: Firmware download link or local path
   Firmware type: Firmware source type
   Example: <Firmware link> <Firmware type>:<SGSI Name>
   Other args:
    [fb]: Don't Fix bugs in Rom
    [i]: Build image only(Processed/Failed)
EOT
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --help|-h|-?)
    usage
    exit 1
    shift
    ;;
    --fb|-fb)
    fixbug="--fb"
    shift
    ;;
    --ab|-ab)
    build=AB
    shift
    ;;
    --a|-a)
    build=A
    shift
    ;;
    --11|-11)
    ver=11
    shift
    ;;
    --12|-12)
    ver=12
    shift
    ;;
    --13|-13)
    ver=13
    shift
    ;;
    --i|-i)
    image="--i"
    shift
    ;;
    --t|-t)
    dummy=true
    shift
    ;;
    *)
    POSITIONAL+=("$1")
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ ! -n $2 ]]; then
    echo "-> ERROR!"
    echo " - Enter all needed parameters"
    usage
    exit 1
fi

URL=$1
shift
TYPE=$1
shift

ORIGINAL_URL=$URL
if [[ $TYPE == *":"* ]]; then
    NAME=`echo "$TYPE" | cut -d ":" -f 2`
else
    NAME=$TYPE
fi
if [[ $TYPE == *":"* ]]; then
    TYPE=`echo "$TYPE" | cut -d ":" -f 1`
else
    TYPE=$TYPE
fi

rm -rf "$LOCALDIR/output" "$LOCALDIR/tmp" "11/output" "12/output" "13/output"
LEAVE() {
    cd $LOCALDIR
    rm -rf "output" "tmp" "11/output" "12/output" "13/output"
    exit 1
}

mkdir -p tmp
#Android 11 SGSI
if [ $ver == 11 ]; then
    "$LOCALDIR"/11/url2SGSI.sh $URL $TYPE:$NAME $image || LEAVE
    mv $LOCALDIR/11/output .
fi

#Android 12 SGSI
if [ $ver == 12 ]; then
    "$LOCALDIR"/12/url2SGSI.sh $URL $TYPE:$NAME $fixbug $image || LEAVE
    mv $LOCALDIR/12/output .
fi

#Android 13 SGSI
if [ $ver == 13 ]; then
    "$LOCALDIR"/13/url2SGSI.sh $URL $TYPE:$NAME $fixbug $image || LEAVE
    mv $LOCALDIR/13/output .
fi

#Clean
./clean.sh > /dev/null 2>&1

if [ -f "$LOCALDIR/output/README.txt" ]; then
   exit 0
else
   LEAVE
fi
