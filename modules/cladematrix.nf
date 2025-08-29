process CLADE_MATRIX {
    maxForks 2
    tag "$clade"
    publishDir "$params.publishDir/snp-matrix/", mode: 'copy', pattern: '*.csv'
    publishDir "$params.matrixCopy/", mode: 'copy', pattern: '*.csv'
    
    input:
        tuple val (clade), path ("${clade}_${params.today}_snp-only.fas")
        val params.today
    
    output:
        tuple val (clade), path ("${clade}_${params.today}_matrix.csv")
    
    script:
    """
    #!/bin/bash
    set -eo pipefail
    
    /snp-dists/snp-dists -c ${clade}_${params.today}_snp-only.fas > ${clade}_${params.today}_matrix.csv
    """
}