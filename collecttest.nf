#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//Define variables
today = params.today
outdir = file(params.outdir)

//Concatenate all FinalOut csv files
Channel
    .fromPath( params.pathTocsv )
    .collectFile(name: 'All_FinalOut.csv', keepHeader: true, newLine: true)
    .set {inputCsv}

process cleandata {
    publishDir "${outdir}", mode: 'copy', pattern: 'bTB_Allclean_*.csv'
    input:
        path ('concat.csv')
    output:
        path ('bTB_Allclean_*.csv')
    """
    addsub.sh concat.csv
    cleanNuniq.sh withsub.csv ${today}
    """
}

process splitclades {
    input:
        path ('clean.csv')
    output:
        path('B*_Pass.csv')
    """
    awk -F, '{print >> (\$9"_"\$7".csv")}' clean.csv
    """
}

process sampleLists{
    tag "$clade"
    publishDir "${outdir}/SampleLists/", mode: 'copy', pattern: '*_samplelist.csv'
    input:
        tuple val(clade), path('*_Pass.csv')
    output:
        tuple val(clade), path('*.csv')
    """
    echo -e "Submission,Sample,GenomeCov,MeanDepth,pcMapped,group,Ncount,ResultLoc"
    awk -F, '{print \$1","\$2","\$3","\$4","\$6","\$9","\$15","\$16}' *_Pass.csv >> "$clade"_${today}_samplelist.csv
    """
}

process cladesnps {
    errorStrategy 'ignore'
    tag "$clade"
    publishDir "${outdir}/snp-fasta/", mode: 'copy', pattern: '*_snp-only.fas'
    input:
        tuple val(clade), path('clade.lst')

//Also need to input maxN and appropriate (pre-selected) root for each clade 
//TODO: Make input table Clade,maxN,pathtoRoot

    output:
        tuple val(clade), path("${clade}_${today}_snp-only.fas")
    """
    concatConsensus.sh clade.lst $clade $today
    """
}

process cladematrix {
    errorStrategy 'ignore'
    tag "$clade"
    publishDir "${outdir}/snp-matrix/", mode: 'copy', pattern: '*.csv'
    input:
        tuple val(clade), path('snp-only.fas')
    output:
        tuple val(clade), path("${clade}_${today}_matrix.csv")
    """
    buildmatrix.sh snp-only.fas $clade $today
    """
}

process growtrees {
    errorStrategy 'ignore'
    tag "$clade"
    publishDir "${outdir}/trees/", mode: 'copy', pattern: '*_MP.nwk'
    input:
        tuple val(clade), path("${clade}_${today}_snp-only.fas")
    output:
        tuple val(clade), path("*_MP.nwk")
    script:
        """
        megatree.sh ${clade}_${today}_snp-only.fas $clade $today $params.maxP200x $params.userMP
        """
}

workflow {
    cleandata(inputCsv)
    splitclades(cleandata.out)
    splitclades.out
        .flatMap()
        .map { file -> def key = file.name.toString().tokenize('_').get(0) 
        return tuple (key, file) 
        }
        .set{ cladelists }
    sampleLists(cladelists)
    cladesnps(sampleLists.out)
    cladematrix(cladesnps.out)
    growtrees(cladesnps.out)
}