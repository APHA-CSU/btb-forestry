#!/usr/bin/env python3

import argparse
import pandas as pd
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord


def refine(multiFasta, droppedList, clade):
    # generate list of samples to be removed
    dropped_df = pd.read_csv(droppedList, dtype='object')
    dropSamples = set(dropped_df['Samples'])

    # Use SeqIO to remove samles from multifasta
    retained = [SeqRecord(id=sample.id, seq=sample.seq, description='')
                for sample in SeqIO.parse(multiFasta, 'fasta')
                if sample.id not in dropSamples]
    SeqIO.write(retained, '{}_refined.fas'.format(clade), 'fasta')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('multiFasta', help='path to input fasta file')
    parser.add_argument('droppedList', help='List of samples to be removed')
    parser.add_argument('clade', help='clade information')

    args = parser.parse_args()

    refine(**vars(args))
