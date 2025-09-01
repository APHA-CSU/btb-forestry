process BACKUP_PROD_DATA {
    
    input:
        path (outdir)
    
    output:
        (stdout)
        
    script:
    """
    s3prod.sh ${outdir}
    """
}