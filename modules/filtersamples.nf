process FILTER_SAMPLES{
    tag "$clade"
    publishDir "$params.publishDir/SampleLists/", mode: 'copy', pattern: '*_samplelist.csv'
    
    input:
        tuple val (clade), path (pass), val (maxN), val (outGroup), val (outGroupLoc)
        path (outliers)
        val (today)

    output:
        tuple val(clade), path('*_samplelist.csv'), emit: includedSamples
        path('*_highN.csv'), emit: excludedSamples

    script:
    """
    filterSamples.sh $pass $clade $today $maxN $outliers
    """
}