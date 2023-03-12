#!/bin/bash

sudo su
apt udpate

cd zmap
apt-get install build-essential cmake libgmp3-dev gengetopt libpcap-dev flex byacc libjson-c-dev pkg-config libunistring-dev
cmake .
make -j4
make install

# dminer
apt install python3-pip
pip3 install diamond-miner pycaracal pych-client
# pip3 install 'pych-client<0.3.0,>=0.2.3'

python3 -m site | grep "site-packages"
echo "ATTENTION: modify -- filter_private: bool = False"
sed -i "s/filter_private: bool = True/filter_private: bool = False/" /usr/local/lib/python3.10/dist-packages/diamond_miner/queries/query.py

apt install -y docker
apt install -y docker.io
docker run --rm -d -p 8123:8123 clickhouse/clickhouse-server:22.6

cp results_template results -r
mkdir results_zip

chmod 400 /home/ubuntu/.ssh/Ohio-rsa.pem
scp -i /home/ubuntu/.ssh/Ohio-rsa.pem README.md  ubuntu@3.142.185.31:/home/ubuntu/collections/

ulimit -n 65535
ulimit -a
