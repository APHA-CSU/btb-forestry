#!/usr/bin/env python3

import pandas as pd
import argparse
from datetime import date


# determine if sample is not Mbovis or is contaminated
def exclusionBasis(ID, Outcome):
    if ID != 'Mycobacterium bovis':
        return 'Not M.bovis'
    elif Outcome != 'Pass':
        return 'Impure culture'
    else:
        return ''


def exclusions(allclean_csv, highN_csv, outliers_list):

    highN_df = pd.read_csv(highN_csv, dtype='object')
    # add column to specify low qual data
    highN_df['Exclusion'] = 'Low quality data'
    highN_df = highN_df[['Submission', 'Exclusion']]

    outliers_df = pd.read_csv(outliers_list, dtype='object')
    outliers_df.columns.values[0] = "Submission"
    # add column to indicate that sample has been identified as an outlier
    outliers_df['Exclusion'] = 'Identified Outlier'

    allClean_df = pd.read_csv(allclean_csv, dtype='object')
    allClean_df.columns.values[0] = "Submission"
    # add column with reason for exclusion
    allClean_df['Exclusion'] = allClean_df.apply(lambda x: exclusionBasis(x['ID'], x['Outcome']), axis=1)
    failed_df = allClean_df[['Submission', 'Exclusion']]
    failed_df = failed_df[failed_df['Exclusion'] != '']

    # concatenate all outputs
    excludedSamples = [failed_df, outliers_df, highN_df]
    excluded_df = pd.concat(excludedSamples, ignore_index=True)
    excluded_df.sort_values(by=['Submission'], inplace=True)

    date_out = date.today().strftime('%d%b%y')

    excluded_df.to_csv('allExcluded_{}.csv'.format(date_out), index=False, header=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('allclean_csv', help='path to Allclean.csv')
    parser.add_argument('highN_csv', help='path to highN.csv')
    parser.add_argument('outliers_list', help='path to outliers.txt')

    args = parser.parse_args()

    exclusions(**vars(args))
