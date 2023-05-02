#!/bin/bash

set -eo pipefail

clean=$1

# Separate sample list based on clade and outcome
awk -F, '{print >> ($9"_"$7".csv")}' $clean
