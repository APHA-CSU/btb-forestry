#!/usr/bin/env python3

import glob
import pandas as pd
import subprocess

from bin import filterMetadata
from bin import cladeMetadata
from bin import formatLocations

## Tests ##
"""
This uses the pytest framework to ensure that the various data filtering parts 
of this pipeline function as expected.  Generally this is done by processing 
small dummy data files and asserting that the outcomes match expectations. 
Similar approaches can be used for bash and python scripts.
"""

#addsub
def test_addsub():
    subprocess.run(["bin/addsub.sh", "tests/data/subtest.csv"], check=True)
    withsub_df = pd.read_csv('withsub.csv')
    addsubexp_df = pd.read_csv('tests/data/subtest_exp.csv')
    pd.testing.assert_frame_equal(withsub_df, addsubexp_df)

#cleanNuniq
def test_cleanNuniq():
    subprocess.run(["bin/cleanNuniq.sh", "tests/data/subtest_exp.csv", "test"], check=True)
    cleanNuniq_df = pd.read_csv('bTB_Allclean_test.csv')
    cleanNuniqexp_df = pd.read_csv('tests/data/Allclean_exp.csv')
    pd.testing.assert_frame_equal(cleanNuniq_df, cleanNuniqexp_df)

#metadata
def test_metadata():
    filterMetadata.filter('tests/data/metaTest.csv')
    csv_files = glob.glob('sortedMetadata_*.csv') #required as file is generated with date stamp
    csv_file_path = ''.join(csv_files)
    output_df = pd.read_csv(csv_file_path)
    expected_df = pd.read_csv('tests/data/filterMeta_exp.csv')
    pd.testing.assert_frame_equal(output_df, expected_df)

#clademeta
def test_clademeta():
    cladeMetadata.combine('tests/data/filterMeta_exp.csv', 'tests/data/samplelist.csv', 'test')
    csv_files = glob.glob('test_metadata_*.csv') #required as file is generated with date stamp
    csv_file_path = ''.join(csv_files)
    output_df = pd.read_csv(csv_file_path)
    expected_df = pd.read_csv('tests/data/cladeMeta_exp.csv')
    pd.testing.assert_frame_equal(output_df, expected_df)

"""
#filtersamples
def test_filtersamples():
    subprocess.run(["bin/filterSamples.sh", "fulllist", "clade", "today", "maxN", "outlierList"], check=True)

#formatLocations
def test_formatlocations():
    formatLocations.locationfix('tests/data/location.csv', 'test/data/counties.tsv')

#
"""
