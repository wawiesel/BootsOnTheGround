#!/usr/bin/env sh
set -evx
env | sort
cmake --version
curl --version

mkdir build || true
cd build
cmake ..
make
ctest

