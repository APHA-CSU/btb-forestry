#!/bin/bash

set -eo pipefail

clean=$1

# Separate sample list based on clade and outcome
awk -F, '{print >> (\$9"_"\$7".csv")}' $clean

# Generate list of files containing low quality samples
lowqual=$(ls *.csv | grep -v _Pass | grep -v clean)

# Concatenate low quality samples into single file
cat $lowqaul > lowQual.csv
