#!/bin/bash

# Extract relevant fields from clade lists, remove pre-determined outliers and
# filter on Ncount

fulllist=$1
clade=$2
maxN=$3
outlierList=$4

while IFS= read Sample
do
    sed -i "/^$Sample/d" $fulllist
done <$outlierList

echo -e "Submission,Sample,GenomeCov,MeanDepth,pcMapped,group,Ncount,ResultLoc" > ${clade}_${params.today}_samplelist.csv
awk -F, '$15 <= '$maxN' {print \$1","\$2","\$3","\$4","\$6","\$9","\$15","\$16}' $fulllist >> ${clade}_${params.today}_samplelist.csv
