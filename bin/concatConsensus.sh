#!/bin/bash

set -eo pipefail

cladelist=$1
clade=$2
today=$3
#maxN=$3

while IFS=, read -r Sample Ncount Path;
do
    #if "$Ncount" > "$maxN"
    echo "Path is: $Path"
    aws s3 cp "${Path}consensus/${Sample}_consensus.fas" "${Sample}_consensus.fas"
    #fi
done <$cladelist

cat *_consensus.fas > ${clade}_AllConsensus.fas
rm *_consensus.fas
snp-sites -c -o ${clade}_${today}_snp-only.fas ${clade}_AllConsensus.fas
rm *_AllConsensus.fas