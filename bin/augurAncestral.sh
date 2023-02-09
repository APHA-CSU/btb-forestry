#!/bin/bash

set -eo pipefail

clade=$1
today=$2
inputfasta=$3
rootedtree=$4

# This process identifies ancestral sequences for each node in the tree.
# https://docs.nextstrain.org/projects/augur/en/stable/usage/cli/ancestral.html

augur ancestral -a $inputfasta \
    -t $rootedtree \
    --output-node-data ${clade}_${today}_nt-muts.json \
    --inference joint
