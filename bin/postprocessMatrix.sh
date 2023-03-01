#!/bin/bash

set -eo pipefail

file=$1
IFS=","
read -ra samples <<< $(head -n 1 $file)
subno_array=()
for sample in "${samples[@]}"
    do  
        subno=$(bash extractSub.sh $sample)
        subno_array+=( "$subno" )
    done
headers=${subno_array[*]}
echo "$headers" >> post_process_matrix.csv
cat post_process_matrix.csv
i=0
sed 1d $file | while IFS= read -r line;
do
    i=$i+1
    echo -e "${subno_array[$i]},$( echo $line | cut -d ',' -f1 --complement )" >> post_process_matrix.csv
done
