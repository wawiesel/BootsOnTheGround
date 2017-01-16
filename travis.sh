#!/usr/bin/env sh
set -evx
env | sort
cmake --version

mkdir build || true
cd build
cmake ..
make
ctest

