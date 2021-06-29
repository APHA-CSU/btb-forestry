#!/bin/bash

set -e

samplelist=$1
clade=$2

expsize=4349904 # M.bovis genome size (AF2122-97 - LT708304)
maxbad=217495 # Expect 95% to be called base (A/C/G/T)



# From a given list of samples find the consensus object and retrieve from the s3 bucket. Check that
# the consensus is the correct length and is at least 95% good sequence; remove if not.
while IFS= read sample
do
    echo "Looking for consensus for $sample"
    s3object=$(grep -m1 "$sample"_consensus.fas ConsensusList.txt | awk '{print $4}')
    if [ ! -z $s3object ]
        then
        aws s3 cp s3://s3-csu-003/$s3object $PWD/SelectedConsensus/
        size=$(cat SelectedConsensus/"$sample"_consensus.fas | awk '$0 !~ ">" {c+=length($0);} END { print c; }')
        badseq=$(grep -o 'N' SelectedConsensus/"$sample"_consensus.fas | wc -l)
            if [ "$size" -ne "$expsize" ];
            then
            rm SelectedConsensus/"$sample"_consensus.fas
            echo $sample >> WrongLength.txt
            elif [ "$badseq" -gt "$maxbad" ];
            then
            rm SelectedConsensus/"$sample"_consensus.fas
            echo $sample >> LowQual.txt
            else
            echo $sample >> Included.txt
            fi
        else echo $sample >> Notfound.txt
    fi

done <"$samplelist"

cat SelectedConsensus/*_consensus.fas > "$clade"_allSamples.fas
rm -r SelectedConsensus