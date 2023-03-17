#!bin/bash

scripts_path=/root/network-measurements/scripts
results_path=/root/network-measurements/results
zip_path=/root/network-measurements/results_zip
prefix_path=/root/network-measurements/results
log_file=/root/network-measurements/log.16
makeup_path=/root/network-measurements/results_zip/0.0.0.0_12

if [ -f ${makeup_path}.tar.gz ]
then
	tar -xzf ${makeup_path}.tar.gz -C ${zip_path}
fi

mkdir ${results_path}
while read -r prefix12; do
	prefix12_stripped="${prefix12//\//_}"
	echo -n "# " >> ${log_file}
	echo -n `TZ=America/Detroit date +%R` >> ${log_file}
	echo -e "\tAnalyzing ${prefix12}" >> ${log_file}
	tar -xzf ${zip_path}/${prefix12_stripped}.tar.gz -C ${zip_path}

	mkdir -p ${results_path}/${prefix12_stripped}
	while read -r prefix16; do
		prefix16_stripped="${prefix16//\//_}"
		# echo -n -e "\t\t${prefix16}: " >> ${log_file}
		if [ -f ${makeup_path}/${prefix16_stripped}.dminer1 ]
		then
			python3 scripts/cal-coverage-dminer.py ${makeup_path}/${prefix16_stripped}.dminer1 \
				${makeup_path}/${prefix16_stripped}.dminer2 \
				${results_path}/${prefix12_stripped}/${prefix16_stripped}.links >> ${log_file}
		else
			python3 scripts/cal-coverage-dminer.py ${zip_path}/${prefix12_stripped}/${prefix16_stripped}.dminer1 \
				${zip_path}/${prefix12_stripped}/${prefix16_stripped}.dminer2 \
				${results_path}/${prefix12_stripped}/${prefix16_stripped}.links >> ${log_file}
		fi
	done <${zip_path}/${prefix12_stripped}/16.prefixes

	rm ${zip_path}/${prefix12_stripped} -r
	echo -n "# " >> ${log_file}
	echo -n `TZ=America/Detroit date +%R` >> ${log_file}
	echo -e "\tDone ${prefix12}" >> ${log_file}
done <${zip_path}/12.prefixes

echo -n "# " >> ${log_file}
echo -n `TZ=America/Detroit date +%R`
echo -e "\tDone all"
