#!/bin/bash

set -e

snpfile=$1

echo "Computing tree"
megacc -a 'dirname "$0"'/infer_MP_nucleotide_200x.mao -d $snpfile