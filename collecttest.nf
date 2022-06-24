#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Config
params.pathTocsv = "$PWD/**/*FinalOut*.csv"

//Concatenate all FinalOut csv files
Channel
    .fromPath( params.pathTocsv )
    .collectFile(name: 'All_FinalOut.csv', keepHeader: true, newLine: true)
    .set {inputCsv}

process stripcomments {
    input:
    path ('concat.csv')
    output:
    path ('clean.csv')
    """
    sed '/^#/d' concat.csv > clean.csv
    """
}

process splitclades{
    input:
    path ('clean.csv')
    output:
    path('B*_Pass.csv')
    """
    awk -F, '{print >> (\$8"_"\$6".csv")}' clean.csv
    """
}

process gatherconsensus{
    tag "$clade"
    publishDir "$PWD/Test/SampleLists/", mode: 'symlink', pattern: '*.lst'
    input:
    tuple val(clade), path('*_Pass.csv')
    output:
    tuple val(clade), path('*.lst')
    """
    awk -F, '{print \$1","\$14","\$15}' *_Pass.csv > "$clade"_samples.lst
    """
}



workflow {
    stripcomments(inputCsv)
    splitclades(stripcomments.out)
    splitclades.out
        .flatMap()
        .map { file -> def key = file.name.toString().tokenize('_').get(0) 
        return tuple (key, file) 
        }
        .set{ cladelists }
    gatherconsensus(cladelists)
}