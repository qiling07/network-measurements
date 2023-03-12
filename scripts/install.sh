#!/bin/bash

apt update

cd zmap
apt-get install -y build-essential cmake libgmp3-dev gengetopt libpcap-dev flex byacc libjson-c-dev pkg-config libunistring-dev
cmake .
make -j4
make install
cd ..

# dminer
apt install -y python3-pip
pip3 install diamond-miner pycaracal pych-client

python3 -m site | grep "site-packages"
sed -i "s/filter_private: bool = True/filter_private: bool = False/" /usr/local/lib/python3.10/dist-packages/diamond_miner/queries/query.py

apt install -y docker
apt install -y docker.io
docker run --rm -d -p 8123:8123 clickhouse/clickhouse-server:22.6

cp results_template results -r
mkdir results_zip

chmod 400 ~/.ssh/Ohio-rsa.pem
scp -i ~/.ssh/Ohio-rsa.pem README.md ubuntu@3.142.185.31:/home/ubuntu/collections/trash/

ulimit -n 65535
ulimit -a
