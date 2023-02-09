#!/usr/bin/env python3

import glob
import pandas as pd
import subprocess

from bin import filterMetadata
from bin import cladeMetadata

#Tests

#addsub
def test_addsub():
    subprocess.run(["bin/addsub.sh", "tests/data/subtest.csv"], check=True)
    withsub_df = pd.read_csv('withsub.csv')
    addsubexp_df = pd.read_csv('tests/data/subtest_exp.csv')
    assert all(withsub_df == addsubexp_df)

#cleanNuniq
def test_cleanNuniq():
    subprocess.run(["bin/cleanNuniq.sh", "tests/data/subtest_exp.csv", "test"], check=True)
    cleanNuniq_df = pd.read_csv('bTB_Allclean_test.csv')
    cleanNuniqexp_df = pd.read_csv('tests/data/Allclean_exp.csv')
    assert all(cleanNuniq_df == cleanNuniqexp_df)

#metadata
def test_metadata():
    filterMetadata.filter('tests/data/metatest.csv')
    csv_files = glob.glob('sortedMetadata_*.csv')
    csv_file_path = ''.join(csv_files)
    output_df=pd.read_csv(csv_file_path)
    expected_df=pd.read_csv('tests/data/sortedMeta_exp.csv')
    assert all(output_df == expected_df)

"""
#clademeta
def test_clademeta():
    cladeMetadata.combine('data/filtermeta.csv')

#filtersamples
def test_filtersamples():
    subprocess.run(["bin/filterSamples.sh", "fulllist", "clade", "today", "maxN", "outlierList"], check=True)

"""
