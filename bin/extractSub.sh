#!/bin/bash

# Extracts submission number from a sample number using regex (*-nn-(n)nnnn-nn). 

set -eo pipefail

sample=$(echo "$1" | awk -F, '/[A-Z]*-*[0-9]{2,2}-[0-9]{4,5}-[0-9]{2,2}*/ {print $1}');
if [[ -z $sample ]];
    then subno=$1
else
    IFS=-, read -r -a array <<< $sample
    if [[ ${array[0]} = [A-Z]* ]]; 
        then fivedig=$(echo "${array[2]}" | sed 's/\b[0-9]\{4\}\b/0&/1')
            year=$(echo ${array[3]} | sed 's/^\(.\{2\}\).*$/\1/')
            subno=$(echo AF-${array[1]}-$fivedig-$year); 
        else fivedig=$(echo "${array[1]}" | sed 's/\b[0-9]\{4\}\b/0&/1')
            year=$(echo ${array[2]} | sed 's/^\(.\{2\}\).*$/\1/')
            subno=$(echo AF-${array[0]}-$fivedig-$year);
    fi
fi
echo $subno