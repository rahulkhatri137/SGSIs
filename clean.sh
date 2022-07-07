#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR

cd 11
rm -rf tmp out SGSI images
cd ..
cd 12
rm -rf tmp out workspace SGSI
cd ..
cd 13
rm -rf tmp out workspace SGSI
cd $LOCALDIR
