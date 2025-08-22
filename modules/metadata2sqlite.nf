process METADATA_2_SQLITE {
    publishDir "$params.publishDir/Metadata/", mode: 'copy'
    input:
        path('filteredWgsMeta.csv')
        path('metadata.csv')
        path('movements.csv')
        path('locations.csv')
        path('all_excluded.csv')
    output:
        path('viewbovis.db')
    script:
    """
    metadata2sqlite.py filteredWgsMeta.csv metadata.csv movements.csv locations.csv all_excluded.csv
    """
}