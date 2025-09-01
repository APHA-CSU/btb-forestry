process CLADE_MATRIX {
    errorStrategy 'ignore'
    maxForks 2
    tag "$clade"
    publishDir "$params.publishDir/snp-matrix/", mode: 'copy', pattern: '*.csv'
    publishDir "$params.matrixCopy", mode: 'copy', pattern: '*.csv'
    
    input:
        tuple val (clade), path ("${clade}_${today}_snp-only.fas")
        val (today)
    
    output:
        tuple val (clade), path ("${clade}_${today}_matrix.csv")
    
    script:
    """
    #!/bin/bash
    set -eo pipefail
    
    /snp-dists/snp-dists -c ${clade}_${today}_snp-only.fas > ${clade}_${today}_matrix.csv
    """
}