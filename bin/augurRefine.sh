#!/bin/bash

set -eo pipefail

clade=$1
today=$2
outGroup=$3

augur refine -a ${clade}_${today}_snp-only.fas \
            -t ${clade}_${today}_MP.nwk \
            --root $outgroup \
            --output-tree ${clade}_${today}_MP-rooted.nwk \
            --output-node-data ${clade}_${today}_phylo.json \
            --divergence-units mutations
