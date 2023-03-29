#!/usr/bin/env python3

import sqlite3
import argparse

import pandas as pd

"""
    Builds a sqlite database from 'metadata' and 'latlon' csv files.
    Writes one database file, 'viewbovis.db', to the working directory.
"""


def convert_to_sqlite(wgs_metadata_path, submissions_path, movements_path,
                      latlon_path):
    conn = sqlite3.connect("viewbovis.db")
    # write filtered wgs metadata to sqlite db
    df_wgs_metadata = pd.read_csv(wgs_metadata_path, index_col="Submission",
                                  dtype=str)
    df_wgs_metadata.to_sql("wgs_metadata", con=conn, if_exists="replace")
    # write submissions to sqlite db
    df_submissions = pd.read_csv(submissions_path, index_col="Submission",
                                 dtype=str)
    df_submissions.to_sql("submissions", con=conn, if_exists="replace")
    # write movements to sqlite db
    df_movements = pd.read_csv(movements_path, index_col="Submission",
                               dtype=str)
    df_movements.to_sql("movements", con=conn, if_exists="replace")
    # write lat-lon data to sqlite db
    df_locations = pd.read_csv(latlon_path, index_col="CPH",
                               dtype={"CPH": str, "Lat": float, "Long": float})
    df_locations.to_sql("latlon", con=conn, if_exists="replace")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('wgs_metadata_path',
                        help='path to filteredWgsMetadata.csv')
    parser.add_argument('submissions_path', help='path to submissions.csv')
    parser.add_argument('movements_path', help='path to movements.csv')
    parser.add_argument('latlon_path', help='path to latlon.csv')
    args = parser.parse_args()
    convert_to_sqlite(**vars(args))
