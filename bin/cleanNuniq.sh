#!/bin/bash

set -eo pipefail

concat=$1 # concatenated csv input
today=$2 # datestamp

# Bash pipe which removes the comment lines from the csv, then sorts on sample 
# name and 'Ncount', and where there are duplicate sample names only the entry 
# with the lowest 'Ncount' is retained

#TODO Need to add function to ensure that Pass samples are retained over non-Pass samples
# even if they have a higher Ncount

head -n 1 $concat > bTB_Allclean_${today}.csv && tail -n +2 $concat | # retain the header
    (sort -t ',' -k1,1 -n -k16,16 | # simple sort on colums containing submission and Ncount
    sort -u -t ',' -k1,1 |
    sed '/^#/d') >> bTB_Allclean_${today}.csv # Remove duplicate submisions
