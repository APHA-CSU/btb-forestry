#!/usr/bin/env python3

import pandas as pd
import subprocess

#from bin import filterMetadata
#from bin import cladeMetadata

#Tests
#addsub

def test_addsub():
    subprocess.run(['bin/addsub.sh', "data/subtest.csv"])
    #expected results from subtest.csv:
    #AF-23-01234-56,99.9,100,100000,95
    #AF-78-09012-34,99.9,100,100000,95

#cleanNuniq
#metadata
"""
def test_metadata():
    filterMetadata.filter('data/metatest.csv')
    output_df=pd.read_csv('tmp/*.csv')
    expected_df=pd.read_csv('data/expectedmeta.csv')
    assert output_df == expected_df

def test_clademeta():
    cladeMetadata.combine('data/filtermeta.csv')

#clademeta
"""
