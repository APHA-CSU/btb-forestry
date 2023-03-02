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
echo "$headers" >> ${clade}_${today}_matrix.csv
i=1
IFS= 
sed 1d $snp_matrix | while read -r line;
do
    echo -e "${subno_array[$i]},$( echo $line | cut -d ',' -f1 --complement )" >> ${clade}_${today}_matrix.csv
    i=$i+1
done
