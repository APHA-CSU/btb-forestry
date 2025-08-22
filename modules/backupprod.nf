process BACKUP_PROD_DATA {
    output:
        stdout 
    script:
    """
    s3prod.sh ${params.outdir}
    """
}