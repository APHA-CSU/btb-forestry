#!/bin/bash

set -eo pipefail

clade=$1
today=$2
outGroup=$3
inputfasta=$4
inputtree=$5

# This process roots the tree using the outgroup and exports branch lengths in 
# json format: 
# https://docs.nextstrain.org/projects/augur/en/stable/usage/cli/refine.html
# The general format of .json files is given here: 
# https://docs.nextstrain.org/projects/augur/en/stable/usage/json_format.html

augur refine -a $inputfasta \
            -t $inputtree \
            --root $outGroup \
            --output-tree ${clade}_${today}_MP-rooted.nwk \
            --output-node-data ${clade}_${today}_phylo.json \
            --divergence-units mutations

sed -i 's/"branch_length": 0//g' ${clade}_${today}_phylo.json