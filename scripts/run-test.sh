#!/bin/bash

##################### path
continent=NA
scripts_path=${HOME}/measurement/scripts
results_path=${HOME}/measurement/results
prefix_path=${HOME}/measurement/prefixes

count=0
while read -r prefix; do
	count=$(( $count + 1 ))
	prefix_stripped="${prefix//\//_}"

	if [ $(( $count % 10 )) == 0 ]
	then
		echo "dminer twice -- ${count}th prefix -- ${prefix}.dminer12"
		echo "dminer twice -- ${count}th prefix -- ${prefix}" >> ${results_path}/dminer.log
		sudo python3 ${scripts_path}/yarrp.py ${prefix} 10000 ${results_path}/${prefix_stripped}.dminer1 &>> ${results_path}/dminer.log
		sudo python3 ${scripts_path}/yarrp.py ${prefix} 10000 ${results_path}/${prefix_stripped}.dminer2 &>> ${results_path}/dminer.log
	else
		echo "dminer once -- ${count}th prefix -- ${prefix}.dminer"
		echo "dminer once -- ${count}th prefix -- ${prefix}" >> ${results_path}/dminer.log
		sudo python3 ${scripts_path}/yarrp.py ${prefix} 10000 ${results_path}/${prefix_stripped}.dminer &>> ${results_path}/dminer.log
	fi


	echo "zmap -- ${count}th prefix -- ${prefix}.zmap"
	echo "zmap -- ${count}th prefix -- ${prefix}" >> ${results_path}/zmap.log
	sudo zmap ${prefix}  -M udp --probe-args=latency:0000 -p 53 -r 10000 -t 210 -c 5 -i eth0 \
		--output-file=${results_path}/${prefix_stripped}.zmap \
		--metadata-file=${results_path}/temp.metadata \
		--output-fields="icmp_responder,saddr,icmp_type,icmp_code,icmp_timestamp,icmp_rtt, origin_ttl" \
		&>>${results_path}/zmap.log
	cat ${results_path}/temp.metadata >> ${results_path}/zmap.metadata

	echo "zcomplement -- ${count}th prefix -- ${prefix}.zcomplement"
	echo "zcomplement -- ${count}th prefix -- ${prefix}" >> ${results_path}/zcomplement.log
	sudo zmap ${prefix}  -M udp --probe-args=latency:0000 -p 100 -r 10000 -t 210 -c 5 -i eth0 \
		--output-file=${results_path}/${prefix_stripped}.zcomplement \
		--metadata-file=${results_path}/temp.metadata \
		--output-fields="icmp_responder,saddr,icmp_type,icmp_code,icmp_timestamp,icmp_rtt, origin_ttl" \
		&>>${results_path}/zcomplement.log
	cat ${results_path}/temp.metadata >> ${results_path}/zcomplement.metadata

	echo "------------------------------------------------"
done <${prefix_path}/${continent}-trial.prefix
