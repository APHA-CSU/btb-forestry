process SORT_META_DATA {
    
    input:
        path (metadata)
        path (movements)
        val (today)

    output:
        path ('sortedMetadata_*.csv')

    script:
    """
    filterMetadata.py $metadata $movements $today
    """
}