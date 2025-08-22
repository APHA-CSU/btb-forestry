process GROW_TREES {
    errorStrategy 'ignore'
    maxForks 2
    cpus 4
    tag "$clade"
    input:
        tuple val(clade), path('snp-only.fas'), path('maxP200x.mao'), path('userMP.mao')
    output:
        tuple val(clade), path("*_MP.nwk")
    script:
    """
    megatree.sh snp-only.fas $clade ${params.today} maxP200x.mao userMP.mao
    """
}