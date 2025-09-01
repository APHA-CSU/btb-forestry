process LOCATIONS {

    input:
        path (locations)
        path (counties)
        val (today)

    output:
        path ('allLocations_*.tsv')
        
    script:
    """
    formatLocations.py ${locations} ${counties} ${today}
    """
}