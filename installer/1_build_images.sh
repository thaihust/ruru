#!/bin/bash

source env.sh

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

dockerfile_analytics=analytics
dockerfile_frontend=frontend

function update_dockerfile {
    rm -f ../analytics/Dockerfile
    rm -f ../frontend/Dockerfile
    cp ${CUR_DIR}/dockerfiles/${dockerfile_analytics} ../analytics/Dockerfile
    cp ${CUR_DIR}/dockerfiles/${dockerfile_frontend} ../frontend/Dockerfile
    sed -i "s/PROXY/${PROXY}/g" ../analytics/Dockerfile
    sed -i "s/PROXY/${PROXY}/g" ../frontend/Dockerfile
}

function build_frontend_image {
    cd ../frontend/
    sudo docker build -t frontend .
}

function install_sqlite3 {
    sudo -E add-apt-repository ppa:jonathonf/backports
    sudo apt-get update && sudo apt-get -y install sqlite3
}

function create_analytics_databases {
    cd ../analytics/data/
    rm -f asn.db proxy.db
    touch asn.db proxy.db
    sqlite3 asn.db < importcsv_asn.sql 
    sqlite3 proxy.db < importcsv_proxy.sql
}

function build_analytics_image {
    install_sqlite3
    create_analytics_databases
    cd ../analytics/
    git submodule update --init --recursive
    sudo docker build -t analytics . 
}

function main {
    update_dockerfile
    build_frontend_image
    build_analytics_image
}

main
