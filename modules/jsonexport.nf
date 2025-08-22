process JSON_EXPORT {
    errorStrategy 'ignore'
    tag "$clade"
    publishDir "$params.publishDir/jsonExport/", mode: 'copy'
    input:
        tuple val(clade), path("MP-rooted.nwk"), path("phylo.json"), path('metadata.csv'), path('locations.tsv'), path('config.json'), path('custom-colours.tsv')
    output:
        tuple val(clade), path("*.json")
    script:
    """
    augurExport.sh $clade ${params.today} MP-rooted.nwk phylo.json metadata.csv locations.tsv config.json custom-colours.tsv
    """
}