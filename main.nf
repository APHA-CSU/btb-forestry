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
    cleanNuniq.sh withsub.csv ${params.today} outliers.txt
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

//Tidy up list of samples for each clade
process sampleLists{
    tag "$clade"
    publishDir "$publishDir/SampleLists/", mode: 'copy', pattern: '*_samplelist.csv'
    input:
        tuple val(clade), path('Pass.csv')
    output:
        tuple val(clade), path('*.csv')
    """
    echo -e "Submission,Sample,GenomeCov,MeanDepth,pcMapped,group,Ncount,ResultLoc" > ${clade}_${params.today}_samplelist.csv
    awk -F, '{print \$1","\$2","\$3","\$4","\$6","\$9","\$15","\$16}' Pass.csv >> ${clade}_${params.today}_samplelist.csv
    """
}

process cladesnps {
    errorStrategy 'ignore'
    tag "$clade"
    publishDir "$publishDir/snp-fasta/", mode: 'copy', pattern: '*_snp-only.fas'
    input:
        tuple val(clade), path('clade.lst'), val(maxN), val(outGroup), val(outGroupLoc), path ('outliers.txt')
    output:
        tuple val(clade), path("${clade}_${params.today}_snp-only.fas")
    """
    concatConsensus.sh clade.lst $clade ${params.today} $maxN $outGroup $outGroupLoc
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
        .set{ cladelists }
    
    sampleLists(cladelists)
    
    sampleLists.out
        .join(cladeInfo)
        .combine(outlierList)
        .set { cladeSamples }

    cladesnps(cladeSamples)
    cladematrix(cladesnps.out)
    growtrees(cladesnps.out)
}