process GROW_TREES {
    errorStrategy 'ignore'
    maxForks 2
    cpus 4
    tag "$clade"
    
    input:
        tuple val (clade), path (snp_only)
        path maxP200x
        path userMP
        val today
    
    output:
        tuple val(clade), path("*_MP.nwk")
    
    script:
    """
    #!/bin/bash
    set -eo pipefail

    # Use Megacc (https://www.megasoftware.net/) to build maximum parsimony tree.
    # A two step process is required to add branch lengths

    # Builds MP tree using 200 bootstrap iterations
    megacc -a ${maxP200x} \
        -d ${snp_only} \
        -o baseMP

    # Calculates branch lengths for consensus MP tree
    megacc -a ${userMP} \
        -d ${snp_only} \
        -t baseMP_consensus.nwk \
        -o ${clade}_${today}_MP
    """
}