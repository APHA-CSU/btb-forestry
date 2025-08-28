process LOCATIONS {
    input:
        path ('locations.csv')
        path ('counties.tsv')
    output:
        path ('allLocations_*.tsv')
    script:
    """
    formatLocations.py locations.csv counties.tsv ${params.outdir}
    """
}