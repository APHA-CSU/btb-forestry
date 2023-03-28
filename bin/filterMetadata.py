#!/usr/bin/env python3

# Filter metadata table

import pandas as pd
import numpy as np
import argparse
from datetime import date


# Determine if sample has movement history (True/False)
def moveTF(Loc0, CPH):
    if Loc0 == CPH:
        return 'False'
    elif Loc0 == 'NA':
        return 'False'
    else:
        return 'True'


# Clean up metadata, and add movement summary
def filter(metadata_csv, movement_csv):

    date_out = date.today().strftime('%d%b%y')

    metadata_df = pd.read_csv(metadata_csv, dtype='object')
    metadata_df.set_index('Submission', inplace=True)

    # fix extra spaces and fill empty cells
    metadata_df['CPH'].replace(' ', '', regex=True, inplace=True)
    metadata_df['CPHH'].replace(' ', '', regex=True, inplace=True)
    metadata_df.replace(r'^\s*$', np.nan, regex=True, inplace=True)
    metadata_df.fillna('NA', inplace=True)

    # move_count = metadata_df.iloc[:, 20::5].notnull().sum(axis=1)

    # Indicate if there is a history of cattle movement (True/False)
    metadata_df['PreviousMovement'] = metadata_df.apply(lambda x: moveTF(x['Loc0'], x['CPH']), axis=1)
    # metadata_df['MoveCount'] = move_count

    # write revised metadata file
    metadata_df.to_csv('sortedMetadata_{}.csv'.format(date_out))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('metadata_csv', help='path to metadata.csv')
    parser.add_argument('movement_csv', help='path to movement.csv')

    args = parser.parse_args()

    filter(**vars(args))
