#!/bin/bash

set -eo pipefail

cladelist=$1
clade=$2
today=$3
outGroup=$4
outGroupLoc=$5
parsite=$6


# Collects and concatenates all consensus fasts files in the given input list
# (from s3).
# snp-sites (https://github.com/sanger-pathogens/snp-sites) is then run to 
# generate snp-only fasta files.  Intermediary files are removed to save disk
# space 

while IFS=, read -r Submission Sample GenomeCov MeanDepth pcMapped group Ncount Path;
do
    aws s3 cp "${Path}consensus/${Sample}_consensus.fas" "${Sample}_consensus.fas";
done < <(tail -n +2 $cladelist)

# Add outgroup fasta (outgroup is predetermined for each clade)
aws s3 cp "${outGroupLoc}consensus/${outGroup}_consensus.fas" "${outGroup}_consensus.fas"

cat *_consensus.fas > ${clade}_AllConsensus.fas
rm *_consensus.fas
snp-sites -c -o ${clade}_${today}_snp-only.fas ${clade}_AllConsensus.fas
rm *_AllConsensus.fas

# Determine number of samples and SNPs in clade
sam_snp=$(awk '!/^>/ {print length}' ${clade}_${today}_snp-only.fas | uniq -c | sed 's/^ *//')
IFS=' ' read -r numsam numsnp <<< $sam_snp
if (($numsnp < $parsite)); then
    echo "Reduced diversity!: Expected $parsite, but only $numsnp SNPs for ${clade}" > ${clade}_${today}_warnings.txt
else
    echo "$numsnp SNPs for ${clade}" > ${clade}_${today}_snpcount.txt
fi
 