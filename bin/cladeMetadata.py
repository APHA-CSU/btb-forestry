#!/usr/bin/env python3

import pandas as pd
import argparse

"""
This extracts information from the filtered metadata file (sortedMetadata_csv)
by merging with the list of samples in a given clade (cladelist_csv) into
separate files for each clade. It therefore combines the sequencing metrics for
each sample with the additional metadata. The file is then suitable for Augur.
"""


def combine(sortedMetadata_csv, cladelist_csv, clade, today):

    date_out = today

    sortedMetadata_df = pd.read_csv(sortedMetadata_csv, dtype='object')
    cladelist_df = pd.read_csv(cladelist_csv)

    clademetadata_df = pd.merge(cladelist_df, sortedMetadata_df, on='Submission', how='left')
    clademetadata_df.rename(columns={'Sample': 'name'}, inplace=True)
    clademetadata_df.set_index('Submission', inplace=True)

    clademetadata_df.to_csv('{}_metadata_{}.csv'.format(clade, date_out))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('sortedMetadata_csv', help='path to sortedMetadata.csv')
    parser.add_argument('cladelist_csv', help='path to clade list')
    parser.add_argument('clade', help='clade identifier')
    parser.add_argument('today', help='date')

    args = parser.parse_args()

    combine(**vars(args))
