#!/bin/bash

sudo su
apt-get udpate

cd zmap
apt-get install build-essential cmake libgmp3-dev gengetopt libpcap-dev flex byacc libjson-c-dev pkg-config libunistring-dev
cmake .
make -j4
make install

# dminer
apt install python3-pip
pip3 install diamond-miner pycaracal pych-client

python3 -m site | grep "site-packages"
echo "ATTENTION: modify -- filter_private: bool = False"

docker run --rm -d -p 8123:8123 clickhouse/clickhouse-server:22.6
