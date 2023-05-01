#!/usr/bin/env python3

import pandas as pd
import argparse
from datetime import date


#def isMbovis(lowQual_df.iloc[:, 16]):
#    if lowQual_df.iloc[:, 16] == 'Mycobacterium bovis':
    


def exclusions(negative_csv, lowQual_csv, highN_csv):

    negative_df = pd.read_csv(negative_csv, dtype='object')
    
    lowQual_df = pd.read_csv(lowQual_csv, dtype='object')
    lowQual_df.insert(1, 'Excluded', 'N/A')
    #if not Mbovis say so
    lowQual_df.loc[(lowQual_df.iloc[:, 16] !=  Mycobacterium bovis), 'Excluded'] = 'not M.bovis'


    


    highN_df = pd.read_csv(highN_csv, dtype='object')



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('negative_csv', help='path to negative.csv')
    parser.add_argument('lowQaul_csv', help='path to lowQual.csv')
    parser.add_argument('highN_csv', help='path to highN.csv')

    args = parser.parse_args()

    exclusions(**vars(args))
