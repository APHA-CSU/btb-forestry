#!/bin/bash

set -eo pipefail

clade=$1
today=$2
inputfasta=$3
rootedtree=$4

augur ancestral -a $inputfasta \
    -t $rootedtree \
    --output-node-data ${clade}_${today}_nt-muts.json \
    --inference joint
