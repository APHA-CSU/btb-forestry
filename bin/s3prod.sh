#!/bin/bash

set -eo pipefail

S3_PATH=$1

# backup production files
# skip the backup stage if the prod/ folder is missing in $S3_PATH
{
    # extract date of current production files from $S3_PATH
    aws s3 cp ${S3_PATH}/btb-forest_prod/Metadata/metadata.json metadata_prod.json &&
    {
	backup_date=($(sed -e 's/^"//' -e 's/"$//' <<< $(jq '.today' metadata_prod.json)))
	backup_date=${backup_date[0]}

	# backup current production files in $S3_PATH
	aws s3 mv --recursive ${S3_PATH}/btb-forest_prod/ ${S3_PATH}/btb-forest_${backup_date}/ --acl bucket-owner-full-control
    }
}
