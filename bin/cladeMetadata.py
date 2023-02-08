#!/usr/bin/env python3

import pandas as pd
import argparse
from datetime import date

"""
This splits the filtered metadata file into separate files for each clade. It
also combines the sequencing metrics for the sample with the additional 
metadata. The file is then suitable for Augur.
"""

def combine(sortedMetadata_csv, cladelist_csv, clade):

    date_out=date.today().strftime('%d%b%y')

    sortedMetadata_df = pd.read_csv(sortedMetadata_csv)
    cladelist_df = pd.read_csv(cladelist_csv)

    clademetadata_df = pd.merge(cladelist_df, sortedMetadata_df, on = 'Submission', how='left')
    clademetadata_df.rename(columns = {'Sample': 'name'}, inplace=True)
    clademetadata_df.set_index('Submission', inplace=True)

    clademetadata_df.to_csv('{}_metadata_{}.csv'.format(clade, date_out))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('sortedMetadata_csv', help='path to sortedMetadata.csv')
    parser.add_argument('cladelist_csv', help='path to clade list')
    parser.add_argument('clade', help='clade identifier')
        
    args = parser.parse_args()

    combine(**vars(args))
