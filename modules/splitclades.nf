process SPLIT_CLADES {

    input:
        path (clean)

    output:
        path('B*_Pass.csv'), emit: passSamples

    script:
    """
    splitClades.sh $clean
    """
}