process FORESTRY_META_DATA {
    publishDir "$params.publishDir/Metadata/", mode: 'copy'
    
    input:
        val go
        val today
    
    output:
        path('metadata.json')
    
    script:
    """
    #!/bin/bash
    set -eo pipefail
    
    jq -n --arg jq_date $today --arg jq_commit $workflow.commitId '{"today": \$jq_date, "git_commit": \$jq_commit}' > metadata.json
    """
}