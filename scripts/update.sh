#!/bin/bash

LOCALDIR=`cd "$( dirname ${BASH_SOURCE[0]} )" && pwd`
cd $LOCALDIR/..

if [ ! -d ".git" ];then
        echo "Forcing updating"
        git init
        git checkout -b main
        git remote add origin https://github.com/rahulkhatri137/SGSIs.git
        git fetch https://github.com/rahulkhatri137/SGSIs.git main
        git remote -v
        git reset --hard FETCH_HEAD
        git clean -df
        git pull origin main
        git branch --set-upstream-to=origin/main
fi

