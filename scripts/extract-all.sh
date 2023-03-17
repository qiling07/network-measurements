#!bin/bash

scripts_path=/home/ubuntu/network-measurements/scripts
results_path=/home/ubuntu/network-measurements/results
zip_path=/home/ubuntu/network-measurements/results_zip
prefix_path=/home/ubuntu/network-measurements/results
log_file=/home/ubuntu/network-measurements/log2

mkdir ${results_path}/${continent}

while read -r prefix12; do
	prefix12_stripped="${prefix12//\//_}"
	echo -n `TZ=America/Detroit date +%R` >> ${log_file}
	echo -e "\tAnalyzing ${prefix12}" >> ${log_file}
	tar -xzf ${zip_path}/${prefix12_stripped}.tar.gz -C ${zip_path}

	mkdir -p ${results_path}/${continent}/${prefix12_stripped}
	while read -r prefix16; do
		prefix16_stripped="${prefix16//\//_}"
		echo -n -e "\t\t${prefix16}: " >> ${log_file}
		python3 scripts/cal-coverage-dminer.py ${zip_path}/${prefix12_stripped}/${prefix16_stripped}.dminer1 \
			${zip_path}/${prefix12_stripped}/${prefix16_stripped}.dminer2 \
			${results_path}/${continent}/${prefix12_stripped}/${prefix16_stripped}.links >> ${log_file}
	done <${zip_path}/${prefix12_stripped}/16.prefixes

	rm ${zip_path}/${prefix12_stripped} -r
	echo -n `TZ=America/Detroit date +%R` >> ${log_file}
	echo -e "\tDone ${prefix12}" >> ${log_file}
done <${zip_path}/12.prefixes

echo -n `TZ=America/Detroit date +%R`
echo -e "\tDone all"
