process FILTER_SAMPLES{
    tag "$clade"
    publishDir "$params.publishDir/SampleLists/", mode: 'copy', pattern: '*_samplelist.csv'
    
    input:
        tuple val (clade), path (pass), val (maxN), val (outGroup), val (outGroupLoc)
        path outliers
        val today

    output:
        tuple val(clade), path('*_samplelist.csv'), emit: includedSamples
        path('*_highN.csv'), emit: excludedSamples

    script:
    """
    #!/bin/bash
    set -eo pipefail

    while IFS= read Sample
    do
        sed -i "/^\$Sample/d" ${pass}
    done < ${outliers}
    
    echo -e "Submission,Sample,GenomeCov,MeanDepth,pcMapped,group,Ncount,ResultLoc" > ${clade}_${today}_samplelist.csv
    awk -F, '\$15 <= '${maxN}' {print \$1","\$2","\$3","\$4","\$6","\$9","\$15","\$16}' ${pass} >> ${clade}_${today}_samplelist.csv
    
    echo -e "Submission,Sample,GenomeCov,MeanDepth,pcMapped,group,Ncount,ResultLoc" > ${clade}_${today}_highN.csv
    awk -F, '\$15 > '${maxN}' {print \$1","\$2","\$3","\$4","\$6","\$9","\$15","\$16}' ${pass} >> ${clade}_${today}_highN.csv
    """
}