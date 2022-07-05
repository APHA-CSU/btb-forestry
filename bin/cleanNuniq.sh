#!/bin/bash

set -eo pipefail

concat=$1 # concatenated csv input

# Bash pipe which removes the comment lines from the csv, then sorts on sample 
# name and 'Ncount', and where there are duplicate sample names only the entry 
# with the lowest 'Ncount' is retained

sed '/^#/d' $concat |
    (head -n 1 && tail -n +2 | # retain the header
    sort -t ',' -k1,1 -k14,14 |
    sort -u -t ',' -k1,1) > clean.csv