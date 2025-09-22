#!/usr/bin/env python3

# Filter metadata table

import pandas as pd
import argparse

# Determine if sample has movement history (True/False)
def moveTF(Loc0, CPH):
    if Loc0 == CPH:
        return 'False'
    elif Loc0 == 'NA':
        return 'False'
    else:
        return 'True'


# Clean up metadata, and add movement summary
def filter(metadata_csv, movement_csv, today):

    date_out = today

    # Extract number of movements from movement.csv
    movement_df = pd.read_csv(movement_csv, index_col='Submission')
    movement_df.sort_values(by=['Submission', 'Loc_Num'], inplace=True)
    movement_df = movement_df[~movement_df.index.duplicated(keep='last')]
    move_count = (movement_df['Loc_Num'] - 1)
    move_count[move_count < 0] = 0

    # Fix extra spaces and fill empty cells in metadata
    metadata_df = pd.read_csv(metadata_csv, dtype='object',
                              index_col='Submission')
    metadata_df.replace({'CPH': ' ', 'Gender': ' '}, '', regex=True, inplace=True)
    metadata_df.replace({'Gender': 'N'}, '', regex=True, inplace=True)
    metadata_df.replace({'Host': 'COW'}, 'BOVINE', regex=False, inplace=True)
    metadata_df.replace({r'^\s*$', ''}, regex=True, inplace=True)
    metadata_df.fillna('NA', inplace=True)

    # Indicate if there is a history of cattle movement (True/False)
    metadata_df['PreviousMovement'] = metadata_df.apply(
        lambda x: moveTF(x['Loc0'], x['CPH']), axis=1)
    metadata_df.rename(columns={'CPH': 'PreciseLocation'}, inplace=True)
    metadata_df['MoveCount'] = move_count.astype(str)

    # write revised metadata file
    metadata_df.to_csv('sortedMetadata_{}.csv'.format(date_out))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('metadata_csv', help='path to metadata.csv')
    parser.add_argument('movement_csv', help='path to movement.csv')
    parser.add_argument('today', help='date')

    args = parser.parse_args()

    filter(**vars(args))
