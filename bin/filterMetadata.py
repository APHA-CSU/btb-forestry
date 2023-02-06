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
    metadata_df.sort_values('MovementId', kind='mergesort', inplace = True)
    metadata_df.sort_values('SampleName', kind='mergesort', inplace = True)
    metadata_df.set_index('SampleName', inplace = True)
    
    metadata_df.to_csv('sortedMetadata_{}.csv'.format(date_out))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('metadata_csv', help='path to AssignedWGSClade.csv')
    #parser.add_argument('bovis_csv', help='path to Bovis.csv')
    
    args = parser.parse_args()

    filter(**vars(args))