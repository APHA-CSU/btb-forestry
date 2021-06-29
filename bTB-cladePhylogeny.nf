#!/usr/bin/env nextflow

nextflow.enable.dsl=2

lists = Channel.fromPath( "$PWD/*_samples.txt" )
            .map { file -> tuple(file.baseName.split("_")[0], file) }

process availableConsensusList {
    
    output:
        path 'ConsensusList.txt'
    script:
    """
    consensusList.sh
    """
}
/*
process cladesamples {
    output: 
        
    script:
        """
        ??
        """
}

process filternewsamples {

}
*/
process accumulateCladeConsensus {
    tag "$clade"
    input:
        path 'ConsensusList.txt'
        tuple val(clade), path("${clade}_samples.txt")
    output:
        tuple val(clade), path("${clade}_allSamples.fas")
    script:
        """
        accumulateCladeConsensus.sh ${clade}_samples.txt ${clade}
        """
}

process filterSNPs {
    tag "$clade"
    input: 
        tuple val(clade), path("${clade}_allSamples.fas")
    output:
        tuple val(clade), path("${clade}_snp-only.fas")
    script:
        """
        snp-sites -c -o ${clade}_snp-only.fas ${clade}_allSamples.fas
        """
}

process growtrees {
    tag "$clade"
    input:
        tuple val(clade), path("${clade}_snp-only.fas")
    output:
        tuple val(clade), path("M10CC_Out/${clade}_*.nwk")
    script:
        """
        megacc -a $baseDir/accessory/infer_MP_nucleotide_200x.mao -d ${clade}_snp-only.fas
        """
}
/*
process plantforest {

}
 */
workflow {
    availableConsensusList()
    //cladesamples()
    //filternewsamples()
    accumulateCladeConsensus(availableConsensusList.out,lists) 
    filterSNPs(accumulateCladeConsensus.out)
    growtrees(filterSNPs.out)
    //plantforest()
}