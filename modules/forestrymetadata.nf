process FORESTRY_META_DATA {
    publishDir "$params.publishDir/Metadata/", mode: 'copy'
    
    input:
        val go
        val today
    
    output:
        path('metadata.json')
    
    script:
    """
    forestMeta.sh $today $workflow.commitId
    """
}