process CLADE_SNPS {
    errorStrategy 'retry'
    maxRetries 2
    maxForks 6
    tag "$clade"
    publishDir "$params.publishDir/snp-fasta/", mode: 'copy', pattern: '*_snp-only.fas'

    input:
        tuple val (clade), path (cladelst), val (maxN), val (outGroup), val (outGroupLoc)
        val (today)

    output:
        tuple val (clade), path ("${clade}_${today}_snp-only.fas")

    script:
    """
    concatConsensus.sh $cladelst $clade $today $outGroup $outGroupLoc
    """
}