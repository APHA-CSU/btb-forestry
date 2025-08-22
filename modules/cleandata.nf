process CLEAN_DATA {
    publishDir "$params.publishDir", mode: 'copy', pattern: 'bTB_Allclean_*.csv'
    input:
        path ('concat.csv')
        
    output:
        path ('bTB_Allclean_*.csv')
    script:
    """
    addsub.sh concat.csv
    cleanNuniq.sh withsub.csv ${params.today}
    """
}