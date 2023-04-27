#!/bin/bash

set -eo pipefail

awk -F, '{print >> (\$9"_"\$7".csv")}' clean.csv
lowqual=$(ls *.csv | grep -v _Pass | grep -v clean)
cat $lowqaul > LowQual.csv
