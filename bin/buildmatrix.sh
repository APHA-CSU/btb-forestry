#!/bin/bash

set -eo pipefail

snponlyfasta=$1
clade=$2
today=$3
maxN=$4
outGroup=$5

# Runs snp-dists (https://github.com/tseemann/snp-dists) to generate distance 
# matrix using output from snp-sites

~/snp-dists/snp-dists -c $snponlyfasta > ${clade}_${today}_matrix.csv

#$projectDir/bin/matrixStats.py ${clade}_${today}_matrix.csv ${maxN} ${outGroup} ${clade}
