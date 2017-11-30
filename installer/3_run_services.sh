#!/bin/bash

source env.sh
CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function start_container_services { 
    docker run -d -p 127.0.0.1:8086:8086 -p 8083:8083 -e INFLUXDB_ADMIN_ENABLED=true --name influxdb -v ../influxdb:/var/lib/influxdb influxdb
    sleep 3
    INFLUXDB_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' influxdb)
    
    docker run -d -p 3001:3001 -p 3000:3000 -p 127.0.0.1:6080:6080 -e MAPBOX_TOKEN='${MAPBOX_TOKEN}' -e INFLUX_HOST='${INFLUXDB_IP}' --name frontend frontend 
    sleep 3
    FRONTEND_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' frontend)
    
    docker run -d -p 5502:5502 -p 5503:5503 -e http_proxy= -e https_proxy= --name analytics analytics ./analytics --bind tcp://0.0.0.0:5502 tcp://0.0.0.0:5503 --publish tcp://${FRONTEND_IP}:6080 --influx http://${INFLUXDB_IP}:8086/write?db=rtt
    sleep 3
    
    docker run -d -p 4000:3000 -v ../grafana:/var/lib/grafana -e "GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASS}" --name grafana grafana/grafana 
}

function start_dpdk_latency {
    cd ../dpdk-latency/
    ANALYTICS_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' analytics)
    ./build/dpdk-latency -c ${DPDK_CORE_MASK} -n ${DPDK_NUM_MEM_CHANNELS} -- -p ${DPDK_LATENCY_PORT_MASK} -T ${DPDK_LATENCY_INTERVAL} --config "(0,0,1),(0,0,2),(0,0,3)" --publishto ${ANALYTICS_IP}
}

function main {
   start_container_services
   start_dpdk_latency
}

export DPDK_CORE_MASK=f
export DPDK_NUM_MEM_CHANNELS=4
export DPDK_LATENCY_PORT_MASK=1
export DPDK_LATENCY_INTERVAL=20
