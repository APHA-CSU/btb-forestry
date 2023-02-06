#!/usr/bin/env python3

# Filter metadata table

import pandas as pd
import argparse
import os
from datetime import datetime, date

def filter(metadata_csv):

    date_out = date.today().strftime('%d%b%y')

    metadata_df = pd.read_csv(metadata_csv)
    metadata_df['SampleName']=metadata_df['SampleName'].astype(object)
    # sort and deduplicate the metadata
    metadata_df.sort_values('SampleName', kind='mergesort', inplace = True)
    metadata_df.sort_values('MovementId', kind='mergesort', inplace = True)
    metadata_df.drop_duplicates('SampleName', inplace = True)
    metadata_df.rename(columns = {'SampleName': 'Submission'}, inplace = True)
    metadata_df.set_index('Submission', inplace = True)

    # remove surplus columns
    metadata_df.drop(metadata_df.iloc[:, 13:30], inplace = True, axis = 1)
        
    # write revised metadata file
    metadata_df.to_csv('sortedMetadata_{}.csv'.format(date_out))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('metadata_csv', help='path to AssignedWGSClade.csv')
    
    args = parser.parse_args()

    filter(**vars(args))
    