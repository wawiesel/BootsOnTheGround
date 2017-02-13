#!/bin/bash

if [[ "$1" == "" ]]
then
    args=".."
else
    args="$@"
fi

BOTG_SCRIPT_DIR=$(dirname $0)
XCOL=$BOTG_SCRIPT_DIR/contrib/xcol/xcolorize.sh
cmake -Wno-dev $args 2>&1 | $XCOL \
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
| tee >($BOTG_SCRIPT_DIR/contrib/ansi2html/ansi2html.sh --bg=dark >botg-config.html)
