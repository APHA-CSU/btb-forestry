process JSON_EXPORT {
    errorStrategy 'ignore'
    tag "$clade"
    publishDir "$params.publishDir/jsonExport/", mode: 'copy'
    input:
        tuple val (clade), path (MP_rooted), path (phylo), path (metadata), path (locations)
        path (config)
        path (colours)
        val (today)
    output:
        tuple val (clade), path ("*.json")
    script:
    """
    augurExport.sh $clade $today $MP_rooted $phylo $metadata $locations $config $colours
    """
}