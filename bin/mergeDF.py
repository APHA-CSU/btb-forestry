#!/usr/bin/env python3

import argparse
import pandas as pd
import numpy as np


def merge(newmeta_csv, origmeta_csv, locations_csv):
    newmeta_df = pd.read_csv(newmeta_csv, dtype='object', index_col='Submission')
    newmeta_df.replace(r'^\s*$', np.nan, regex=True, inplace=True)
    origmeta_df = pd.read_csv(origmeta_csv, dtype='object', index_col='Submission')
    origmeta_df.replace(r'^\s*$', np.nan, regex=True, inplace=True)
    fixedmeta_df = newmeta_df.fillna(origmeta_df)
    mergedmeta_df = pd.concat([fixedmeta_df, newmeta_df]).drop_duplicates()
    mergedmeta_df = mergedmeta_df[~mergedmeta_df.index.duplicated(keep='first')]
    mergedmeta_df.to_csv('WarehouseMerged.csv')

# Fix spaces in postcodes
    locations_df = pd.read_csv(locations_csv, dtype='object')
    locations_df['CPH'].replace(' ', '', regex=True, inplace=True)
    locations_df.to_csv('fixedLocations.csv', index=False)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('newmeta_csv', help='path to newdata.csv')
    parser.add_argument('origmeta_csv', help='path to origdata.csv')
    parser.add_argument('locations_csv', help='path to locations.csv')

    args = parser.parse_args()

    merge(**vars(args))
