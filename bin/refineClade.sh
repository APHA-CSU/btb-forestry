#!/bin/bash

set -eo pipefail

clade=$1
multifasta=$2
dropList=$3
outGroup=$4
outGroupLoc=$5

# Run python script to remove entries from multifasta
refineClade.py ${multifasta} ${dropList} ${clade}

# Add outgroup fasta (outgroup is predetermined for each clade)
aws s3 cp "${outGroupLoc}consensus/${outGroup}_consensus.fas" "${outGroup}_consensus.fas"

cat ${clade}_refined.fas "${outGroup}_consensus.fas" > refined_out.fas

# Run snp-sites on refined data
snp-sites -c -o ${clade}_refined_snp-only.fas refined_out.fas

rm refined_out.fas ${clade}_refined.fas
