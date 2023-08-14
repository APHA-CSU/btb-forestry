#!/bin/bash

set -eo pipefail

TODAY=$1

# write metadata.json with today's date
jq -n --arg jq_date $TODAY --arg jq_commit $(git rev-parse HEAD) '{"today": $jq_date, "git_commit": $jq_commit}' > metadata.json
