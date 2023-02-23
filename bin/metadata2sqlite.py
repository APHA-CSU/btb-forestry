#!/usr/bin/env python3

import sqlite3
import argparse

import pandas as pd

def convert_to_sqlite(metadata_csv_path, latlon_csv_path):
    conn = sqlite3.connect("viewbovis.db")
    # write metadata to sqlite db
    df_metadata = pd.read_csv(metadata_csv_path, index_col="Submission", 
                              dtype=str)
    df_metadata.to_sql("metadata", con=conn, if_exists="replace")
    # write lat-lon data to sqlite db
    df_latlon = pd.read_csv(latlon_csv_path, index_col="CPH", 
                            dtype={"CPH": str, 
                                   "Lat": float,
                                   "Long": float})
    df_latlon.to_sql("latlon", con=conn, if_exists="replace")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('metadata_csv_path', help='path to metadata.csv')
    parser.add_argument('latlon_csv_path', help='path to latlon.csv')
    args = parser.parse_args()
    convert_to_sqlite(**vars(args))
