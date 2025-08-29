process BACKUP_PROD_DATA {
    
    input:
        path params.outdir
    
    output:
        stdout
        
    script:
    """
    s3prod.sh ${params.outdir}
    """
}