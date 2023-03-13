#!/bin/bash

ulimit -n 65535

##################### path
continent=$1
if [[ -z "${continent}" ]]; then
	echo "empty continent"
	exit 1
fi

server=$2
if [[ -z "${server}" ]]; then
	echo "empty server"
	exit 1
fi

scripts_path=/home/ubuntu/network-measurements/scripts
results_path=/home/ubuntu/network-measurements/results
zip_path=/home/ubuntu/network-measurements/results_zip
prefix_path=/home/ubuntu/network-measurements/results
log_file=/home/ubuntu/network-measurements/log
myIp=3.142.185.31

count=0
while read -r prefix12; do
	prefix12_stripped="${prefix12//\//_}"
	echo -n `TZ=America/Detroit date +%R` >> ${log_file}
	echo -e "\tSCAN ${prefix12}" >> ${log_file}

	while read -r prefix16; do
		count=$(( $count + 1 ))
		echo -n `TZ=America/Detroit date +%R` >> ${log_file}
		echo -e "\t\tSCAN ${prefix16}" >> ${log_file}

		prefix16_stripped="${prefix16//\//_}"
		results_path16=${results_path}/${continent}/${prefix12_stripped}

		echo -n `TZ=America/Detroit date +%R` >> ${log_file}
		echo -e "\t\tDMINER one -- ${count}th prefix -- ${prefix16}.dminer1" >> ${log_file}
		echo "DMINER one -- ${count}th prefix -- ${prefix16}.dminer1" >> ${results_path16}/dminer.log
		python3 ${scripts_path}/diamond-miner.py ${prefix16} 100000 ${results_path16}/${prefix16_stripped}.dminer1 &>> ${results_path16}/dminer.log

		echo -n `TZ=America/Detroit date +%R` >> ${log_file}
		echo -e "\t\tDMINER two -- ${count}th prefix -- ${prefix16}.dminer2" >> ${log_file}
		echo "DMINER two -- ${count}th prefix -- ${prefix16}.dminer2" >> ${results_path16}/dminer.log
		python3 ${scripts_path}/diamond-miner.py ${prefix16} 100000 ${results_path16}/${prefix16_stripped}.dminer2 &>> ${results_path16}/dminer.log

		echo -n `TZ=America/Detroit date +%R` >> ${log_file}
		echo -e "\t\tZMAP -- ${count}th prefix -- ${prefix16}.zmap" >> ${log_file}
		echo "ZMAP -- ${count}th prefix -- ${prefix16}" >> ${results_path16}/zmap.log
		zmap ${prefix16}  -M udp --probe-args=latency:0000 -p 53 -r 10000 -t 210 -c 5 \
			--output-file=${results_path16}/${prefix16_stripped}.zmap \
			--metadata-file=${results_path16}/temp.metadata \
			--output-fields="icmp_responder,saddr,icmp_type,icmp_code,icmp_timestamp,icmp_rtt, origin_ttl" \
			&>>${results_path16}/zmap.log
		cat ${results_path16}/temp.metadata >> ${results_path16}/zmap.metadata

		echo -n `TZ=America/Detroit date +%R` >> ${log_file}
		echo -e "\t\tZCOMPLEMENT -- ${count}th prefix -- ${prefix16}.zcomplement" >> ${log_file}
		echo "ZCOMPLEMENT -- ${count}th prefix -- ${prefix16}.zcomplement" >> ${results_path16}/zcomplement.log
		zmap ${prefix16}  -M udp --probe-args=latency:0000 -p 100 -r 10000 -t 210 -c 5 \
			--output-file=${results_path16}/${prefix16_stripped}.zcomplement \
			--metadata-file=${results_path16}/temp.metadata \
			--output-fields="icmp_responder,saddr,icmp_type,icmp_code,icmp_timestamp,icmp_rtt, origin_ttl" \
			&>>${results_path16}/zmap.log
		cat ${results_path16}/temp.metadata >> ${results_path16}/zmap.metadata

		echo -n `TZ=America/Detroit date +%R` >> ${log_file}
		echo -e "\t\tDONE ${prefix16}" >> ${log_file}
		echo -e "\t\t------------------------------------------------" >> ${log_file}
	done <${prefix_path}/${continent}/${prefix12_stripped}/16.prefixes

	# cleanup for prefix12
	rm ${results_path}/${continent}/${prefix12_stripped}/temp.metadata
	tar -czf ${zip_path}/${prefix12_stripped}.tar.gz -C ${results_path}/${continent}/ ${prefix12_stripped} --remove-files &
	echo -n `TZ=America/Detroit date +%R` >> ${log_file}
	echo -e "\tDONE ${prefix12}\n" >> ${log_file}
	timeout 2m scp -i /home/ubuntu/.ssh/Ohio-rsa.pem ${log_file} ubuntu@${myIp}:/home/ubuntu/collections/${continent}-${server}.log
done <${prefix_path}/${continent}/12.prefixes
