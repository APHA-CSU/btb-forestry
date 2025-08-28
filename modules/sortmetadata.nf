process SORT_META_DATA {
    input:
        path ('metadata.csv')
        path ('movements.csv')
    output:
        path ('sortedMetadata_*.csv')
    script:
    """
    filterMetadata.py metadata.csv movements.csv ${params.today}
    """
}