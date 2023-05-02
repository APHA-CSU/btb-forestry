#!/usr/bin/env python3

import glob
import pandas as pd
import subprocess

from bin import filterMetadata
from bin import cladeMetadata
from bin import formatLocations
from bin import listExcluded

# Tests #
"""
This uses the pytest framework to ensure that the various data filtering parts
of this pipeline function as expected.  Generally this is done by processing
small dummy data files and asserting that the outcomes match expectations.
Similar approaches can be used for bash and python scripts.
"""


# addsub
def test_addsub():
    subprocess.run(["bin/addsub.sh", "tests/data/subtest.csv"], check=True)
    output_df = pd.read_csv('withsub.csv')
    expected_df = pd.read_csv('tests/data/subtest_exp.csv')
    pd.testing.assert_frame_equal(output_df, expected_df)


# cleanNuniq
def test_cleanNuniq():
    subprocess.run(["bin/cleanNuniq.sh", "tests/data/subtest_exp.csv", "test"], check=True)
    output_df = pd.read_csv('bTB_Allclean_test.csv')
    expected_df = pd.read_csv('tests/data/Allclean_exp.csv')
    pd.testing.assert_frame_equal(output_df, expected_df)


# metadata
def test_metadata():
    filterMetadata.filter('tests/data/metaTest.csv', 'tests/data/moveTest.csv')
    csv_files = glob.glob('sortedMetadata_*.csv')  # required as file is generated with date stamp
    csv_file_path = ''.join(csv_files)
    output_df = pd.read_csv(csv_file_path)
    expected_df = pd.read_csv('tests/data/filterMeta_exp.csv')
    pd.testing.assert_frame_equal(output_df, expected_df)


# clademeta
def test_clademeta():
    cladeMetadata.combine('tests/data/filterMeta_exp.csv', 'tests/data/samplelist.csv', 'test')
    csv_files = glob.glob('test_metadata_*.csv')  # required as file is generated with date stamp
    csv_file_path = ''.join(csv_files)
    output_df = pd.read_csv(csv_file_path)
    expected_df = pd.read_csv('tests/data/cladeMeta_exp.csv')
    pd.testing.assert_frame_equal(output_df, expected_df)


# filtersamples
def test_filtersamples():
    subprocess.run(["bin/filterSamples.sh", 'tests/data/Allclean_exp.csv',
                    'test', 'today', '52532', 'tests/data/testoutlier.txt'], check=True)
    output1_df = pd.read_csv('test_today_samplelist.csv')
    expected1_df = pd.read_csv('tests/data/filterSample_exp.csv')
    pd.testing.assert_frame_equal(output1_df, expected1_df)
    output2_df = pd.read_csv('test_today_highN.csv')
    expected2_df = pd.read_csv('tests/data/highN_exp.csv')
    pd.testing.assert_frame_equal(output2_df, expected2_df)


# formatLocations
def test_formatlocations():
    formatLocations.locationfix('tests/data/location.csv', 'tests/data/counties.tsv')
    allLocations_tsv = glob.glob('allLocations_*.tsv')
    allLocations_tsv_path = ''.join(allLocations_tsv)
    output_df = pd.read_csv(allLocations_tsv_path, sep='\t')
    expected_df = pd.read_csv('tests/data/allLocations_exp.tsv', sep='\t')
    pd.testing.assert_frame_equal(output_df, expected_df)


# listNegatives
def test_listExcluded():
    listExcluded.exclusions('tests/data/Allclean_exp.csv', 'tests/data/highN_exp.csv', 'tests/data/testoutlier.txt')
    allExcluded_csv = glob.glob('allExcluded_*.csv')
    allExcluded_csv_path = ''.join(allExcluded_csv)
    output_df = pd.read_csv(allExcluded_csv_path)
    expected_df = pd.read_csv('tests/data/exclued_exp.csv')
    pd.testing.assert_frame_equal(output_df, expected_df)
