#!/bin/bash

set -eo pipefail

clade=$1
today=$2
outGroup=$3
inputfasta=$4
inputtree=$5

augur refine -a $inputfasta \
            -t $inputtree \
            --root $outGroup \
            --output-tree ${clade}_${today}_MP-rooted.nwk \
            --output-node-data ${clade}_${today}_phylo.json \
            --divergence-units mutations
