#!/bin/bash

set -eo pipefail

snponlyfasta=$1
clade=$2

~/snp-dists/snp-dists -c $snponlyfasta > "$clade"_matrix.csv