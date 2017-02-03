#!/bin/bash

if [[ "$1" == "" ]]
then
    source_dir=".."
else
    source_dir=$1
fi

XCOL=$(dirname $0)/contrib/xcol/xcolorize.sh
cmake $source_dir 2>&1 | $XCOL \
               yellow '\[BootsOnTheGround\].*' \
                 pink '\[hunter\].*' \
                 cyan '^Processing enabled package.*' \
                 cyan '^Final set of enabled TPLs.*' \
                 cyan 'Final set of enabled SE packages.*' \
                 cyan '^Finished configuring.*' \
               purple '^-- Configuring incomplete.*' \
               purple '^-- Configuring done.*' \
               purple '^-- Generating done.*' \
               purple '^-- Build files have been written to.*' \
                  red '^CMake Error.*' \
