#!/bin/bash

LOCALDIR=`cd "$( dirname $0 )" && pwd`
cd $LOCALDIR

HOST=$(uname)
platform=$(uname -m)
export bin=$LOCALDIR/tool_bin
export LD_LIBRARY_PATH=$bin/$HOST/$platform/lib64
export OUTDIR=$LOCALDIR/output
export TARGETDIR=$LOCALDIR/out
export SCRIPTDIR=$LOCALDIR/scripts
export MAKEDIR=$LOCALDIR/make
export FBDIR=$LOCALDIR/fixbug
export DEBLOATDIR=$LOCALDIR/apps_clean
export TMPDIR=$LOCALDIR/tmp