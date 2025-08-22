process FILTER_SAMPLES{
    tag "$clade"
    publishDir "$params.publishDir/SampleLists/", mode: 'copy', pattern: '*_samplelist.csv'
    input:
        tuple val(clade), path('Pass.csv'), val(maxN), val(outGroup), val(outGroupLoc), path ('outliers.txt')
    output:
        tuple val(clade), path('*_samplelist.csv'), emit: includedSamples
        path('*_highN.csv'), emit: excludedSamples
    script:
    """
    filterSamples.sh Pass.csv $clade ${params.today} $maxN outliers.txt
    """
}