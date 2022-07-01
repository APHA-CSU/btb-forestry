#!/bin/bash

set -eo pipefail

snponlyfasta=$1
clade=$2
today=$3

~/snp-dists/snp-dists -c $snponlyfasta > ${clade}_${today}_matrix.csv