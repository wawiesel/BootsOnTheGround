#!/bin/bash

#get absolute path to BOTG_SCRIPT_DIR
BOTG_SCRIPT_DIR=$(cd $(dirname $0) && pwd)

#run sequence of operations
$BOTG_SCRIPT_DIR/botg-config.sh "$1" && \
$BOTG_SCRIPT_DIR/botg-build.sh && \
$BOTG_SCRIPT_DIR/botg-test.sh


