process GROW_TREES {
    errorStrategy 'ignore'
    maxForks 2
    cpus 4
    tag "$clade"
    
    input:
        tuple val (clade), path (snp_only)
        path (maxP200x)
        path (userMP)
        val (today)
    
    output:
        tuple val(clade), path("*_MP.nwk")
    
    script:
    """
    megatree.sh $snp_only $clade $today $maxP200x $userMP
    """
}