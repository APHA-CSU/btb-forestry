process BACKUP_PROD_DATA {
    
    input:
        val outdir
    
    output:
        stdout
    
    script:
    """
    s3prod.sh ${params.outdir}
    """
}