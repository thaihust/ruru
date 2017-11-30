#!/bin/bash

# Script from Moongen repository (https://github.com/libmoon/libmoon)

(
cd $(dirname "${BASH_SOURCE[0]}")
cd deps/dpdk

modprobe uio
(lsmod | grep igb_uio > /dev/null) || insmod ./build/kmod/igb_uio.ko

echo "Binding interface $1 to DPDK"
tools/dpdk-devbind.py  --bind=igb_uio $1

)
