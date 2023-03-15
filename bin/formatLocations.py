#!/usr/bin/env python3

import pandas as pd
import argparse
from datetime import date


def locationfix(location_csv, counties_csv):

    date_out = date.today().strftime('%d%b%y')

    location_df = pd.read_csv(location_csv, dtype='object')
    location_df.insert(0, 'LocationType', 'CPH')

    counties_df = pd.read_csv(counties_csv, dtype='object', sep='\t')

    frames = [location_df, counties_df]
    allLocations_df = pd.concat(frames, ignore_index=True)

    # write updated locations file
    allLocations_df.to_csv('allLocations_{}.tsv'.format(date_out), sep='\t', index=False, header=False)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('location_csv', help='path to locations.csv')
    parser.add_argument('counties_csv', help='path to county locations.csv')

    args = parser.parse_args()

    locationfix(**vars(args))
