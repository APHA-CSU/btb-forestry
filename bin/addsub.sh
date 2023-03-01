#!/bin/bash

# Bash script to add the submission number the first column of the csv file.

set -eo pipefail

file=$1
echo -e "Submission,$(head -n 1 $file)" >> withsub.csv
sed 1d $file | while IFS= read -r line;
do
    IFS="," read -ra line_array <<< $line
    subno=$(bash extractSub.sh ${line_array[0]})
    echo $subno
    echo -e "$subno,$line" >> withsub.csv
done