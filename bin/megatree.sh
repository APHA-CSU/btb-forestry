#!/bin/bash

set -eo pipefail

inputfasta=$1
clade=$2
today=$3
maxP200x=$4
userMP=$5

# Use Megacc (https://www.megasoftware.net/) to build maximum parsimony tree.
# A two step process is required to add branch lengths

megacc -a $maxP200x \
    -d $inputfasta \
    -o baseMP

megacc -a $userMP \
    -d $inputfasta \
    -t baseMP_consensus.nwk \
    -o ${clade}_${today}_MP