#!/usr/bin/env python3

import pandas as pd
import numpy as np
import argparse


def calcBranchMean(matrix_csv, Ncount, outgroup):
    matrix_df = pd.read_csv(matrix_csv, index_col="snp-dists 0.8.2")
    # get min and max outgroup branch length
    nz_df = matrix_df[matrix_df != 0]
    ogbranch = nz_df[outgroup].min()
    maxfromOG = nz_df[outgroup].max()
    # remove outgroup row and column
    noOGmatrix = matrix_df.drop(index=[outgroup], columns=[outgroup])
    # sum all non-zero values in each row
    rowsum = noOGmatrix.sum(numeric_only=True, min_count=1)
    # calculate total branch length
    totalLength = ((rowsum.sum(numeric_only=True))/2)
    # calculate mean branch length
    numSamples = len(noOGmatrix.index)
    pairs = ((numSamples*(numSamples-1))/2)
    meanLength = totalLength/pairs
    # calculate mean of non-zero values
    nz = (np.count_nonzero(noOGmatrix)/2)
    meanNZlength = totalLength/nz
    print(ogbranch, maxfromOG, Ncount, meanLength, meanNZlength)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('matrix_csv', help='path to matrix.csv')
    parser.add_argument('Ncount', help='Ncount threshold for clade')
    parser.add_argument('outgroup', help='outgroup sample for clade')

    args = parser.parse_args()

    calcBranchMean(**vars(args))
