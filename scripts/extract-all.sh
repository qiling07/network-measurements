#!bin/bash

scripts_path=/home/ubuntu/network-measurements/scripts
results_path=/home/ubuntu/network-measurements/results
zip_path=/home/ubuntu/network-measurements/results_zip
prefix_path=/home/ubuntu/network-measurements/results

mkdir ${results_path}/${continent}

while read -r prefix12; do
	prefix12_stripped="${prefix12//\//_}"
	echo -n `TZ=America/Detroit date +%R`
	echo -e "\tEXTRACTING ${prefix12}"
	tar -xzf ${prefix12_stripped}.tar.gz -C ${zip_path}
	mv ${zip_path}/${prefix12_stripped} ${results_path}/${continent}
done <${prefix_path}/${continent}/12.prefixes

echo -n `TZ=America/Detroit date +%R`
echo -e "\tDone all"
