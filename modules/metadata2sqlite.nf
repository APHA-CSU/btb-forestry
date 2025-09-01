process METADATA_2_SQLITE {
    publishDir "$params.publishDir/Metadata/", mode: 'copy'

    input:
        path (filteredWgsMeta)
        path (metadata)
        path (movements)
        path (locations)
        path (excluded)

    output:
        path('viewbovis.db')
        
    script:
    """
    metadata2sqlite.py ${filteredWgsMeta} ${metadata} ${movements} ${locations} ${excluded}
    """
}