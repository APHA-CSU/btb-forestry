#!/bin/bash

set -eo pipefail

snponlyfasta=$1

# Runs snp-dists (https://github.com/tseemann/snp-dists) to generate distance 
# matrix using output from snp-sites

~/snp-dists/snp-dists -c $snponlyfasta > snp_matrix.csv