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

//Tidy up and filter list of samples for each clade
process filterSamples{
    tag "$clade"
    publishDir "$publishDir/SampleLists/", mode: 'copy', pattern: '*_samplelist.csv'
    input:
        tuple val(clade), path('Pass.csv'), val(maxN), val(outGroup), val(outGroupLoc), path ('outliers.txt')
    output:
        tuple val(clade), path('*.csv')
    """
    filterSamples.sh Pass.csv $clade ${params.today} $maxN outliers.txt
    """
}

process cladesnps {
    errorStrategy 'ignore'
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
    tag "$clade"
    publishDir "$publishDir/trees/", mode: 'copy', pattern: '*_MP.nwk'
    input:
        tuple val(clade), path('snp-only.fas')
    output:
        tuple val(clade), path("*_MP.nwk")
    """
    megatree.sh snp-only.fas $clade ${params.today} $params.maxP200x $params.userMP
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
    conda "/home/richardellis/miniconda3/envs/nextstrain/"
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
    conda "/home/richardellis/miniconda3/envs/nextstrain/"
    """
    augurAncestral.sh $clade ${params.today} snp-only.fas MP-rooted.nwk
    """
}

workflow {
    //Concatenate all FinalOut csv files
    Channel
        .fromPath( params.pathTocsv )
        .collectFile(name: 'All_FinalOut.csv', keepHeader: true, newLine: true)
        .set {inputCsv}

    Channel
        .fromPath( params.outliers )
        .set {outlierList}

    Channel.fromPath( params.cladeinfo )
        .splitCsv(header:true)
        .map { row-> tuple(row.clade, row.maxN, row.outgroup, row.outgroupLoc) }
        .set {cladeInfo}

    cleandata(inputCsv)
    splitclades(cleandata.out)

    splitclades.out
        .flatMap()
        .map { file -> def key = file.name.toString().tokenize('_').get(0) 
        return tuple (key, file) 
        }
        .join(cladeInfo)
        .combine(outlierList)
        .set{ cladelists }
    
    filterSamples(cladelists)
    
    filterSamples.out
        .join(cladeInfo)
        .set { cladeSamples }

    cladesnps(cladeSamples)
    cladematrix(cladesnps.out)
    growtrees(cladesnps.out)

    growtrees.out
        .join(cladeInfo)
        .join(cladesnps.out)
        .set { treedata }

    refinetrees(treedata)

    refinetrees.out
        .join(cladesnps.out)
        .set { treesnps }
    
    ancestor(treesnps)
}
