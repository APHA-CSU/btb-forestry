#!/bin/bash

set -eo pipefail

# generate list of non-M.bovis samples

samplelist=$1

grep -v "Mycobacterium bovis" $samplelist > Negative.csv
