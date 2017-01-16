#!/usr/bin/env sh
set -evx
env | sort

mkdir build || true
cd build
curl -O https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.sh
cmake ..
make
ctest

