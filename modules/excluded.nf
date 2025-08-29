process EXCLUDED {
    publishDir "$params.publishDir", mode: 'copy', pattern: 'allExcluded_*.csv'

    input:
        path (allclean)
        path (highn)
        path (outliers)
        val (today)

    output:
        path('allExcluded_*.csv')

    script:
    """
    listExcluded.py $allclean $highn $outliers $today
    """
}