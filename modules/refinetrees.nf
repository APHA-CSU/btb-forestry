process REFINE_TREES {
    errorStrategy 'ignore'
    tag "$clade"
    publishDir "$params.publishDir/augurTrees/", mode: 'copy'
    input:
        tuple val(clade), path("MP.nwk"), val(maxN), val(outGroup), val(outGroupLoc), path("snp-only.fas")
    output:
        tuple val(clade), path("*_MP-rooted.nwk"), path("*_phylo.json")
    script:
    """
    augurRefine.sh $clade ${params.today} $outGroup snp-only.fas MP.nwk
    """
}