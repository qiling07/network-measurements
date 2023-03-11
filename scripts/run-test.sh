#!/bin/bash

ulimit -n 65535

##################### path
continent=$1
if [[ -z "${continent}" ]]; then
	echo "empty continent"
	exit 1
fi

scripts_path=/home/ubuntu/network-measurements/scripts
results_path=/home/ubuntu/network-measurements/results
zip_path=/home/ubuntu/network-measurements/results_zip
prefix_path=/home/ubuntu/network-measurements/results

count=0
while read -r prefix12; do
	prefix12_stripped="${prefix12//\//_}"
	echo "SCAN ${prefix12}"

	while read -r prefix16; do
		count=$(( $count + 1 ))
		echo "\tSCAN ${prefix16}"

		prefix16_stripped="${prefix16//\//_}"
		results_path16=${results_path}/${continent}/${prefix12_stripped}
		if [ $(( $count % 10 )) == 0 ]
		then
			echo "\tDMINER twice -- ${count}th prefix -- ${prefix16}.dminer12"
			echo "DMINER twice -- ${count}th prefix -- ${prefix16}.dminer12" >> ${results_path16}/dminer.log
			python3 ${scripts_path}/diamond-miner.py ${prefix16} 10000 ${results_path16}/${prefix16_stripped}.dminer1 &>> ${results_path16}/dminer.log
			python3 ${scripts_path}/diamond-miner.py ${prefix16} 10000 ${results_path16}/${prefix16_stripped}.dminer2 &>> ${results_path16}/dminer.log
		else
			echo "\tDMINER once -- ${count}th prefix -- ${prefix16}.dminer"
			echo "DMINER once -- ${count}th prefix -- ${prefix16}.dminer" >> ${results_path16}/dminer.log
			python3 ${scripts_path}/diamond-miner.py ${prefix16} 10000 ${results_path16}/${prefix16_stripped}.dminer &>> ${results_path16}/dminer.log
		fi


		echo "\tZMAP -- ${count}th prefix -- ${prefix16}.zmap"
		echo "ZMAP -- ${count}th prefix -- ${prefix16}" >> ${results_path16}/zmap.log
		zmap ${prefix16}  -M udp --probe-args=latency:0000 -p 53 -r 10000 -t 210 -c 5 -i eth0 \
			--output-file=${results_path16}/${prefix16_stripped}.zmap \
			--metadata-file=${results_path16}/temp.metadata \
			--output-fields="icmp_responder,saddr,icmp_type,icmp_code,icmp_timestamp,icmp_rtt, origin_ttl" \
			&>>${results_path16}/zmap.log
		cat ${results_path16}/temp.metadata >> ${results_path16}/zmap.metadata

		echo "\tZCOMPLEMENT -- ${count}th prefix -- ${prefix16}.zcomplement"
		echo "ZCOMPLEMENT -- ${count}th prefix -- ${prefix16}.zcomplement" >> ${results_path16}/zcomplement.log
		zmap ${prefix16}  -M udp --probe-args=latency:0000 -p 100 -r 10000 -t 210 -c 5 -i eth0 \
			--output-file=${results_path16}/${prefix16_stripped}.zcomplement \
			--metadata-file=${results_path16}/temp.metadata \
			--output-fields="icmp_responder,saddr,icmp_type,icmp_code,icmp_timestamp,icmp_rtt, origin_ttl" \
			&>>${results_path16}/zcomplement.log
		cat ${results_path16}/temp.metadata >> ${results_path16}/zcomplement.metadata

		echo "\tDONE ${prefix16}"
		echo "------------------------------------------------"
	done <${prefix_path}/${continent}/${prefix12_stripped}/16.prefixes

	# cleanup for prefix12
	rm ${results_path}/${continent}/${prefix12_stripped}/temp.metadata
	zip -r ${zip_path}/${prefix12_stripped}.zip ${results_path}/${continent}/${prefix12_stripped}
	echo "DONE ${prefix12}\n"
done <${prefix_path}/${continent}/12.prefixes
