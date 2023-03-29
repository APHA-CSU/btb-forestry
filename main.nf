#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//Define variables
publishDir = "$params.outdir/btb-forest_${params.today}/"

process cleandata {
    publishDir "$publishDir", mode: 'copy', pattern: 'bTB_Allclean_*.csv'
    input:
        path ('concat.csv')
    output:
        path ('bTB_Allclean_*.csv')
    """
    addsub.sh concat.csv
    cleanNuniq.sh withsub.csv ${params.today}
    """
}

//Sort metedata csv and retain single line for each submission
process sortsubmissions {
    input:
        path ('submissions.csv')
    output:
        path ('sortedsubmissions_*.csv')
    """
    filtersubmissions.py submissions.csv
    """
}

//Combines warehouse export of locations with exisiting county locations and 
//format correctly for Nextstrain
process locations {
    input:
        path ('locations.csv')
        path ('counties.tsv')
    output:
        path ('allLocations_*.tsv')
    """
    formatLocations.py locations.csv counties.tsv
    """
}

//Splits the main csv based on 'group (clade)' and 'outcome' columns
process splitclades {
    input:
        path ('clean.csv')
    output:
        path('B*_Pass.csv')
    """
    awk -F, '{print >> (\$9"_"\$7".csv")}' clean.csv
    """
}

//Tidy up and filter list of submissions for each clade
process filtersubmissions{
    tag "$clade"
    publishDir "$publishDir/SampleLists/", mode: 'copy', pattern: '*_samplelist.csv'
    input:
        tuple val(clade), path('Pass.csv'), val(maxN), val(outGroup), val(outGroupLoc), path ('outliers.txt')
    output:
        tuple val(clade), path('*.csv')
    """
    filtersubmissions.sh Pass.csv $clade ${params.today} $maxN outliers.txt
    """
}

//Split submissions into separate files for each clade
process cladesubmissions{
    tag "$clade"
    publishDir "$publishDir/submissions/", mode: 'copy', pattern: '*_submissions_*.csv'
    input:
        tuple val(clade), path('cladelist.csv'), path('sortedsubmissions.csv')
    output:
        tuple val(clade), path('*_submissions_*.csv')
    """
    cladesubmissions.py sortedsubmissions.csv cladelist.csv $clade
    """
}

process cladesnps {
    errorStrategy 'retry'
    maxRetries 2
    maxForks 3
    cpus 2
    tag "$clade"
    publishDir "$publishDir/snp-fasta/", mode: 'copy', pattern: '*_snp-only.fas'
    input:
        tuple val(clade), path('clade.lst'), val(maxN), val(outGroup), val(outGroupLoc)
    output:
        tuple val(clade), path("${clade}_${params.today}_snp-only.fas")
    """
    concatConsensus.sh clade.lst $clade ${params.today} $outGroup $outGroupLoc
    """
}

process cladematrix {
    errorStrategy 'ignore'
    maxForks 2
    tag "$clade"
    publishDir "$publishDir/snp-matrix/", mode: 'copy', pattern: '*.csv'
    input:
        tuple val(clade), path('snp-only.fas')
    output:
        tuple val(clade), path("${clade}_${params.today}_matrix.csv")
    """
    buildmatrix.sh snp-only.fas $clade ${params.today}
    """
}

process growtrees {
    errorStrategy 'ignore'
    cpus 4
    tag "$clade"
    publishDir "$publishDir/trees/", mode: 'copy', pattern: '*_MP.nwk'
    input:
        tuple val(clade), path('snp-only.fas'), path('maxP200x.mao'), path('userMP.mao')
    output:
        tuple val(clade), path("*_MP.nwk")
    """
    megatree.sh snp-only.fas $clade ${params.today} maxP200x.mao userMP.mao
    """
}

process refinetrees {
    errorStrategy 'ignore'
    tag "$clade"
    publishDir "$publishDir/augurTrees/", mode: 'copy'
    input:
        tuple val(clade), path("MP.nwk"), val(maxN), val(outGroup), val(outGroupLoc), path("snp-only.fas")
    output:
        tuple val(clade), path("*_MP-rooted.nwk"), path("*_phylo.json")
    //conda "${params.homedir}/miniconda3/envs/nextstrain/"
    """
    augurRefine.sh $clade ${params.today} $outGroup snp-only.fas MP.nwk
    """
}

process ancestor {
    errorStrategy 'ignore'
    tag "$clade"
    publishDir "$publishDir/augurMuts/", mode: 'copy'
    input:
        tuple val(clade), path("MP-rooted.nwk"), path("*_phylo.json"), path("snp-only.fas")
    output:
        tuple val(clade), path("*_nt-muts.json")
    //conda "${params.homedir}/miniconda3/envs/nextstrain/"
    """
    augurAncestral.sh $clade ${params.today} snp-only.fas MP-rooted.nwk
    """
}

process jsonExport {
    errorStrategy 'ignore'
    tag "$clade"
    publishDir "$publishDir/jsonExport/", mode: 'copy'
    input:
        tuple val(clade), path("MP-rooted.nwk"), path("phylo.json"), path("nt-muts.json"), path('submissions.csv'), path('locations.tsv'), path('config.json'), path('custom-colours.tsv')
    output:
        tuple val(clade), path("*.json")
    //conda "${params.homedir}/miniconda3/envs/nextstrain/"
    """
    augurExport.sh $clade ${params.today} MP-rooted.nwk phylo.json nt-muts.json submissions.csv locations.tsv config.json custom-colours.tsv
    """
}

process metadata2sqlite{
    publishDir "$publishDir/submissions/", mode: 'copy'
    input:
        path('filteredWgsMeta.csv')
        path('submissions.csv')
        path('movements.csv')
        path('locations.csv')
    output:
        path('viewbovis.db')
    """
    metadata2sqlite.py filteredWgsMeta.csv submissions.csv movements.csv locations.csv
    """
}

workflow {
    // Concatenate all FinalOut csv files
    Channel
        .fromPath( params.pathTocsv )
        .collectFile(name: 'All_FinalOut.csv', keepHeader: true, newLine: true)
        .set {inputCsv}

    Channel
        .fromPath( params.submissions )
        .set {submissions}

    Channel
        .fromPath( params.movements )
        .set {movements}

    Channel
        .fromPath( params.auspiceconfig )
        .set {auspiceconfig}

    Channel
        .fromPath( params.locations )
        .set {cphlocs}

    Channel
        .fromPath( params.colours )
        .set {colours}

    Channel
        .fromPath( params.counties )
        .set {counties}

    Channel
        .fromPath( params.outliers )
        .set {outlierList}

    Channel.fromPath( params.cladeinfo )
        .splitCsv(header:true)
        .map { row-> tuple(row.clade, row.maxN, row.outgroup, row.outgroupLoc) }
        .set {cladeInfo}
    
    Channel
        .fromPath( params.maxP200x )
        .set {maxP200x}

    Channel
        .fromPath( params.userMP )
        .set {userMP}

    cleandata(inputCsv)

    sortsubmissions(submissions)

    locations(cphlocs, counties)

    splitclades(cleandata.out)

    splitclades.out
        .flatMap()
        .map { file -> def key = file.name.toString().tokenize('_').get(0) 
        return tuple (key, file) 
        }
        .join(cladeInfo)
        .combine(outlierList)
        .set{ cladelists }
    
    filtersubmissions(cladelists)
    
    filtersubmissions.out
        .join(cladeInfo)
        .set { cladesubmissions }

    filtersubmissions.out
        .combine(sortsubmissions.out)
        .set { cladeMeta }
    
    filtersubmissions.out
        .map { it[1] }
        .collectFile(name: 'filteredWgsMeta.csv', keepHeader: true)
        .set { filteredWgsMeta }

    cladesubmissions(cladeMeta)

    cladesnps(cladesubmissions)

    cladematrix(cladesnps.out)

    cladesnps.out
        .combine(maxP200x)
        .combine(userMP)
        .set { megainput }

    growtrees(megainput)

    growtrees.out
        .join(cladeInfo)
        .join(cladesnps.out)
        .set { treedata }

    refinetrees(treedata)

    refinetrees.out
        .join(cladesnps.out)
        .set { treesnps }
    
    ancestor(treesnps)

    refinetrees.out
        .join(ancestor.out)
        .join(cladesubmissions.out)
        .combine(locations.out)
        .combine(auspiceconfig)
        .combine(colours)
        .set { exportData }

    jsonExport(exportData)

    metadata2sqlite(filteredWgsMeta, submissions, movements, cphlocs)
}
