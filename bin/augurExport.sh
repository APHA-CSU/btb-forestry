#!/bin/bash

set -eo pipefail

clade=$1
today=$2
nwktree=$3 
phylojson=$4
ntmutsjson=$5
metadata=$6
locations=$7
configjson=$8
colours=$9

export AUGUR_RECURSION_LIMIT=10000

# This process collects the relavant information and exports in json format for
# direct visualization using Auspice: 
# https://docs.nextstrain.org/projects/augur/en/stable/usage/cli/export.html
# The general format of .json files generated by augur is given here: 
# https://docs.nextstrain.org/projects/augur/en/stable/usage/json_format.html

augur export v2 -t $nwktree \
            --metadata $metadata \
            --node-data $phylojson $ntmutsjson \
            --auspice-config $configjson \
            --color-by-metadata Identifier Host wsdSlaughterDate CPH CPH_Type CPHH County RiskArea \
            --lat-longs $locations \
            --panels tree map \
            --colours custom_colours.tsv \
            --output ${clade}.json

sed -i 's/"#snps": 0//g' ${clade}.json
