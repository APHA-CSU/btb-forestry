#!/usr/bin/env python3

# Filter metadata table

import pandas as pd
import argparse
from datetime import date

def filter(metadata_csv):

    date_out = date.today().strftime('%d%b%y')

    metadata_df = pd.read_csv(metadata_csv, dtype='object')
    metadata_df.set_index('Submission', inplace=True)

    # remove surplus columns
    metadata_df = metadata_df.iloc[:, 1:11]
        
    # write revised metadata file
    metadata_df.to_csv('sortedMetadata_{}.csv'.format(date_out))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('metadata_csv', help='path to metadata.csv')
    
    args = parser.parse_args()

    filter(**vars(args))
    