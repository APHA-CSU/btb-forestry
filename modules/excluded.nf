process EXCLUDED {
    publishDir "$params.publishDir", mode: 'copy', pattern: 'allExcluded_*.csv'
    input:
        path('Allclean.csv')
        path('highN.csv')
        path('outliers.txt')
    output:
        path('allExcluded_*.csv')
    script:
    """
    listExcluded.py Allclean.csv highN.csv outliers.txt
    """
}