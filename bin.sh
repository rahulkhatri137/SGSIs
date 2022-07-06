#!/bin/bash

TOOLDIR=`cd $( dirname ${BASH_SOURCE[0]} ) && pwd`
HOST=$(uname)
platform=$(uname -m)
export bin=$TOOLDIR/tool_bin
export LD_LIBRARY_PATH=$bin/$HOST/$platform/lib64
export IMAGESDIR=$TOOLDIR/images
export TARGETDIR=$TOOLDIR/out
export OUTDIR=$TOOLDIR/output
export SCRIPTDIR=$TOOLDIR/scripts
export MAKEDIR=$TOOLDIR/make
export FBDIR=$TOOLDIR/fixbug
export DEBLOATDIR=$TOOLDIR/apps_clean
export TMPDIR=$TOOLDIR/tmp