process REFINE_TREES {
    errorStrategy 'ignore'
    tag "$clade"
    publishDir "$params.publishDir/augurTrees/", mode: 'copy'

    input:
        tuple val (clade), path (MP_nwk), val (maxN), val (outGroup), val (outGroupLoc), path (snp_only)
        val (today)

    output:
        tuple val (clade), path ("*_MP-rooted.nwk"), path ("*_phylo.json")

    script:
    """
    augurRefine.sh $clade $today $outGroup $snp_only $MP_nwk
    """
}