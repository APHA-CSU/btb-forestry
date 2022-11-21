#!/bin/bash

set -eo pipefail

cladelist=$1
clade=$2
today=$3
maxN=$4
outGroup=$5
outGroupLoc=$6
outlierList=$7

# Removes samples that have been listed as outliers

while IFS= read -r Sample Location
do
    sed -i "/$Sample/d" $cladelist
done <$outlierList

# Collects and concatenates all consensus fasts files in the given input list
# (from s3).  Also filters on the basis of a clade-spcific Ncount threshold.
# snp-sites (https://github.com/sanger-pathogens/snp-sites) is thenrun to 
# generate snp-only fasta files.  Intermediary files are removed to save disk
# space 

while IFS=, read -r Submission Sample GenomeCov MeanDepth pcMapped group Ncount Path;
do
    if [ "$Ncount" -le "$maxN" ];
    then
        echo "Path is: $Path"
        aws s3 cp "${Path}consensus/${Sample}_consensus.fas" "${Sample}_consensus.fas";
    else
        echo "${Sample} skipped: $Ncount greater than permissible for $clade";
    fi
done <$cladelist

# Add outgroup fasta (outgroup is predetermined for each clade)
aws s3 cp "${outGroupLoc}consensus/${outGroup}_consensus.fas" "${outGroup}_consensus.fas"

cat *_consensus.fas > ${clade}_AllConsensus.fas
rm *_consensus.fas
snp-sites -c -o ${clade}_${today}_snp-only.fas ${clade}_AllConsensus.fas
rm *_AllConsensus.fas