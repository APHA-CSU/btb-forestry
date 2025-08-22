process CLADE_SNPS {
    errorStrategy 'retry'
    maxRetries 2
    maxForks 6
    tag "$clade"
    publishDir "$params.publishDir/snp-fasta/", mode: 'copy', pattern: '*_snp-only.fas'
    input:
        tuple val(clade), path('clade.lst'), val(maxN), val(outGroup), val(outGroupLoc)
    output:
        tuple val(clade), path("${clade}_${params.today}_snp-only.fas")
    script:
    """
    concatConsensus.sh clade.lst $clade ${params.today} $outGroup $outGroupLoc
    """
}