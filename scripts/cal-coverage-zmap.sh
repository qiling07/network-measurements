#!/bin/bash

while read -r prefix16; do 
	python3 scripts/cal-coverage-zmap.py results_zip/$1//\//_}/"${prefix16//\//_}.zmap"
done <results_zip/$1/16.prefixes
