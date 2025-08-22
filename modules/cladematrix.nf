process CLADE_MATRIX {
    maxForks 2
    tag "$clade"
    publishDir "$params.publishDir/snp-matrix/", mode: 'copy', pattern: '*.csv'
    publishDir "$params.matrixCopy/", mode: 'copy', pattern: '*.csv'
    input:
        tuple val(clade), path('snp-only.fas')
    output:
        tuple val(clade), path("${clade}_${params.today}_matrix.csv")
    script:
    """
    buildmatrix.sh snp-only.fas $clade ${params.today}
    """
}