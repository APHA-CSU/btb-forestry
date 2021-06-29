#!/bin/bash

set -e

# bucket="s3://s3-csu-003"
# folders=
expsize=4349904 # M.bovis genome size (AF2122-97 - LT708304)
maxbad=217495 # Expect 95% to be called base (A/C/G/T)

# Generate a list of all consensus files on S3.  This is quicker than searching for each required
# consensus file individually.
echo "Building list of available consensus files"
aws s3 ls s3://s3-csu-003/SB4030-TB/ --recursive | grep consensus >> ConsensusList.txt
aws s3 ls s3://s3-csu-003/SB4020-TB/ --recursive | grep consensus >> ConsensusList.txt
aws s3 ls s3://s3-csu-003/SB4300-TB/ --recursive | grep consensus >> ConsensusList.txt
aws s3 ls s3://s3-csu-003/TBOM1089-TB/ --recursive | grep consensus >> ConsensusList.txt