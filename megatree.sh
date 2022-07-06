#!/bin/bash

set -eo pipefail

inputfasta=$1
clade=$2
today=$3

# Use Megacc (https://www.megasoftware.net/) to build maximum parsimony tree.
# A two step process is required to add branch lengths

megacc -a $baseDir/accessory/infer_MP_nucleotide_200x.mao \
    -d $inputfasta \
    -o baseMP
megacc -a $baseDir/accessory/analyze_user_tree_MP__nucleotide.mao \
    -d $inputfasta \
    -t baseMP_consensus.nwk \
    -o ${clade}_${today}_MP