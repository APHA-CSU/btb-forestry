#!/bin/bash

set -eo pipefail

TODAY=$1
GIT_COMMIT=$2

# write metadata.json with today's date
jq -n --arg jq_date $TODAY --arg jq_commit $GIT_COMMIT '{"today": $jq_date, "git_commit": $jq_commit}' > metadata.json
