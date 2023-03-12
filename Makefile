update:
	sudo su
	apt udpate

zmap:
	cd zmap
	apt-get install -y build-essential cmake libgmp3-dev gengetopt libpcap-dev flex byacc libjson-c-dev pkg-config libunistring-dev
	cmake .
	make -j4
	make install

dminer:
	apt install -y python3-pip
	pip3 install diamond-miner pycaracal pych-client
	# pip3 install 'pych-client<0.3.0,>=0.2.3'
	python3 -m site | grep "site-packages"
	echo "ATTENTION: modify -- filter_private: bool = False"

docker:
	apt install -y docker
	apt install -y docker.io
	docker run --rm -d -p 8123:8123 clickhouse/clickhouse-server:22.6
