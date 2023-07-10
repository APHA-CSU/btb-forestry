#!/bin/bash

set -eo pipefail

clade=$1
multifasta=$2
dropList=$3
outGroup=$4
outGroupLoc=$5

awk -vRS=">" -vORS="" -vFS="\n" -vOFS="\n" 'NR>1 && $1!~/'$dropped'/ {print ">"$0}' $multifasta > refined.fas

# Add outgroup fasta (outgroup is predetermined for each clade)
aws s3 cp "${outGroupLoc}consensus/${outGroup}_consensus.fas" "${outGroup}_consensus.fas"

cat refined.fas "${outGroup}_consensus.fas" > refined_out.fas

# Run snp-sites on refined data
snp-sites -c -o ${clade}_${today}_refined_snp-only.fas
