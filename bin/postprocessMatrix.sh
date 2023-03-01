#!/bin/bash

# Converts sample names in the snp matrix to a submission number.

set -eo pipefail

snp_matrix=$1
clade=$2
today=$3

IFS=","
read -ra samples <<< $(head -n 1 $snp_matrix)
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
sed 1d $snp_matrix | while IFS= read -r line;
do
    i=$i+1
    echo -e "${subno_array[$i]},$( echo $line | cut -d ',' -f1 --complement )" >> ${clade}_${today}_matrix.csv
done
