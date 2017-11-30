#!/bin/bash

source env.sh
CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function install_dpdk_latency {
    cd ../dpdk-latency/
    ./build.sh
    ./bind_vif.sh ${VIF}
    export RTE_SDK=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/deps/dpdk
    export RTE_TARGET=x86_64-native-linuxapp-gcc
    make
}

install_dpdk_latency
