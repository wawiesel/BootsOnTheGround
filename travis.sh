#!/usr/bin/env sh
set -evx
env | sort

mkdir build || true
cd build
cmake ..
make
ctest

