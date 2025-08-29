process CLADE_META_DATA{
    tag "$clade"
    publishDir "$params.publishDir/Metadata/", mode: 'copy', pattern: '*_metadata_*.csv'
    
    input:
        tuple val(clade), path('cladelist.csv'), path('sortedmetadata.csv')
        val params.today
    
    output:
        tuple val (clade), path ('*_metadata_*.csv')
    
    script:
    """
    cladeMetadata.py sortedmetadata.csv cladelist.csv $clade $params.today
    """
}