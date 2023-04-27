#!/bin/bash

set -eo pipefail

# Separate sample list based on clade and outcome
awk -F, '{print >> (\$9"_"\$7".csv")}' clean.csv

# Generate list of files containing low quality samples
lowqual=$(ls *.csv | grep -v _Pass | grep -v clean)

# Concatenate low quality samples into single file
cat $lowqaul > LowQual.csv
