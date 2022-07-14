#!/bin/bash

set -eo pipefail

# Bash script to determine submission number from a sample number using regex 
# (*-nn-(n)nnnn-nn). The submission number is then added as the first column of
# the csv file.

#TODO Add code to strip additional characters after year identifier

file=$1
while IFS= read -r line;
do
    sample=$(echo "$line" | awk -F, '/[A-Z]*-*[0-9]{2,2}-[0-9]{4,5}-[0-9]{2,2}/ {print $1}');
    if [[ -z $sample ]];
        then subno=$(echo "$line" | awk -F, '{print $1}');
        else
            IFS=-, read -r -a array <<< $sample
            if [[ ${array[0]} = [A-Z]* ]]; 
                then fivedig=$(echo "${array[2]}" | sed 's/\b[0-9]\{4\}\b/0&/1') 
                    subno=$(echo AF-${array[1]}-${fivedig}-${array[3]}); 
                else fivedig=$(echo "${array[1]}" | sed 's/\b[0-9]\{4\}\b/0&/1')
                    subno=$(echo AF-${array[0]}-${fivedig}-${array[2]});
            fi
        fi
    echo -e "$subno,$line" >> withsub.csv
    
done <"$file"