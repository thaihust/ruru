#!/bin/bash

(
cd $(dirname "${BASH_SOURCE[0]}")
git submodule update --init --recursive

(
cd deps/dpdk
make config T=x86_64-native-linuxapp-gcc
)

(
cd deps/dpdk
make
)

)

