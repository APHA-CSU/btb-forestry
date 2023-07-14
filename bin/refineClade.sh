#!/bin/bash

set -eo pipefail

clade=$1
multifasta=$2
dropList=$3
outGroup=$4
outGroupLoc=$5
fulllist=$6
today=$7

# Run python script to remove entries from multifasta
refineClade.py ${multifasta} ${dropList} ${clade}

# Get full information for retained samples
while IFS=, read Sample pc numN uniqN nonuN score group uniqS
do
    sed -i "/^$Sample/d" $fulllist
done < $dropList | tail -n +2

echo -e "Submission,Sample,GenomeCov,MeanDepth,pcMapped,group,Ncount,ResultLoc" > ${clade}_${today}_samplelist.csv
awk -F, '{print $1","$2","$3","$4","$6","$9","$15","$16}' $fulllist >> ${clade}_${today}_samplelist.csv

# Capture informtion for dropped samples
echo -e "Submission,Sample,GenomeCov,MeanDepth,pcMapped,group,Ncount,ResultLoc" > ${clade}_${today}_highN.csv
while IFS=, read Dropped pc numN uniqN nonuN score group uniqS
do
    awk -v D="$Dropped" '$1==D {print $1","$2","$3","$4","$6","$9","$15","$16}' $fulllist >> ${clade}_${today}_highN.csv
done < $dropList | tail -n +2

# Add outgroup fasta (outgroup is predetermined for each clade)
aws s3 cp "${outGroupLoc}consensus/${outGroup}_consensus.fas" "${outGroup}_consensus.fas"

cat ${clade}_refined.fas "${outGroup}_consensus.fas" > refined_out.fas

# Run snp-sites on refined data
snp-sites -c -o ${clade}_refined_snp-only.fas refined_out.fas

rm refined_out.fas ${clade}_refined.fas
