process FORESTRY_META_DATA {
    publishDir "$params.publishDir/Metadata/", mode: 'copy'
    input:
        val go    
    output:
        path('metadata.json')
        val ()
    script:
    """
    forestMeta.sh ${params.today} ${workflow.commitId}
    """
}