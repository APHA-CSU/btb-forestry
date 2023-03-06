#!/usr/bin/env python3

import sqlite3
import argparse

import pandas as pd

"""
    Builds a sqlite database from 'metadata' and 'latlon' csv files. 
    Writes one database file, 'viewbovis.db', to the working directory.
"""

def convert_to_sqlite(wgs_metadata_path, metadata_path, latlon_path):
    conn = sqlite3.connect("viewbovis.db")
    # write filtered wgs metadata to sqlite db
    df_wgs_metadata = pd.read_csv(wgs_metadata_path, index_col="Submission", 
                                  dtype=str)
    df_wgs_metadata.to_sql("metadata", con=conn, if_exists="replace")
    # write metadata to sqlite db
    df_metadata = pd.read_csv(metadata_path, index_col="Submission", 
                              dtype=str)
    df_metadata.to_sql("metadata", con=conn, if_exists="replace")
    # write lat-lon data to sqlite db
    df_locations = pd.read_csv(latlon_path, index_col="CPH", 
                            dtype={"CPH": str, 
                                   "Lat": float,
                                   "Long": float})
    df_locations.to_sql("latlon", con=conn, if_exists="replace")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('wgs_metadata_path', 
                        help='path to filteredWgsMetadata.csv')
    parser.add_argument('metadata_path', help='path to metadata.csv')
    parser.add_argument('latlon_path', help='path to latlon.csv')
    args = parser.parse_args()
    convert_to_sqlite(**vars(args))
