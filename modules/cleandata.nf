process CLEAN_DATA {
    publishDir "$params.publishDir", mode: 'copy', pattern: 'bTB_Allclean_*.csv'
    
    input:
        path (concat)
        val (today)
        
    output:
        path ('bTB_Allclean_*.csv')
    
    script:
    """
    addsub.sh $concat
    cleanNuniq.sh withsub.csv $today
    """
}