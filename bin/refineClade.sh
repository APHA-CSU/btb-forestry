#!/bin/bash

set -eo pipefail

multifasta=$1
dropList=$2
outGroup=$3
outGroupLoc=$4

awk -vRS=">" -vORS="" -vFS="\n" -vOFS="\n" 'NR>1 && $1!~/'$dropped'/ {print ">"$0}' $multifasta > refined.fas

# Add outgroup fasta (outgroup is predetermined for each clade)
aws s3 cp "${outGroupLoc}consensus/${outGroup}_consensus.fas" "${outGroup}_consensus.fas"

cat refined.fas "${outGroup}_consensus.fas" > refined_out.fas

# Run snp-sites on refined data
snp-sites -c -o ${clade}_${today}_refined_snp-only.fas
