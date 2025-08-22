#!/usr/bin/env nextflow

nextflow.enable.dsl=2
    
// Default values for required parameters
params.pathTocsv = "$PWD/**/*FinalOut*.csv"
params.metadata = "$PWD/metadata.csv"
params.movements = "$PWD/movements.csv"
params.locations = "$PWD/locations.csv"
params.auspiceconfig = "$projectDir/accessory/auspice_config.json"
params.colours = "$projectDir/accessory/custom-colours.tsv"
params.counties = "$projectDir/accessory/counties.tsv"
params.outliers = "$projectDir/accessory/outliers.txt"
params.cladeinfo = "$projectDir/accessory/CladeInfo.csv"
params.today = new Date().format('ddMMMYY')
params.outdir = "$PWD"
params.homedir = "$HOME"
params.prod_run = false
params.matrixdir = "$PWD/matrixcopy"

// Location of megacc analysis options (.mao) files 
params.maxP200x = "$projectDir/accessory/infer_MP_nucleotide_200x.mao"
params.userMP = "$projectDir/accessory/analyze_user_tree_MP__nucleotide.mao"

// Derived params so modules can read them
params.publishDir = params.prod_run
  ? "${params.outdir}/btb-forest_prod/"
  : "${params.outdir}/btb-forest_${params.today}/"

params.matrixCopy = "${params.matrixdir}/SNP_matrix_${params.today}/"

        
/* set modules */

include { BACKUP_PROD_DATA } from './modules/backupprod'
include { CLADE_MATRIX } from './modules/cladematrix'
include { CLADE_META_DATA } from './modules/clademetadata'
include { CLADE_SNPS } from './modules/cladesnps'
include { CLEAN_DATA } from './modules/cleandata'
include { EXCLUDED } from './modules/excluded'
include { FILTER_SAMPLES } from './modules/filtersamples'
include { FORESTRY_META_DATA } from './modules/forestrymetadata'
include { GROW_TREES } from './modules/growtrees'
include { JSON_EXPORT } from './modules/jsonexport'
include { LOCATIONS } from './modules/locations'
include { METADATA_2_SQLITE } from './modules/metadata2sqlite'
include { REFINE_TREES } from './modules/refinetrees'
include { SORT_META_DATA } from './modules/sortmetadata'
include { SPLIT_CLADES } from './modules/splitclades'

workflow {
    // Concatenate all FinalOut csv files
    
    Channel
        .fromPath( params.pathTocsv )
        .collectFile(name: 'All_FinalOut.csv', keepHeader: true, newLine: true)
        .set {inputCsv}

    Channel
        .fromPath( params.metadata )
        .set {metadata}

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

    if( params.prod_run ){
        BACKUP_PROD_DATA()
        FORESTRY_META_DATA(BACKUP_PROD_DATA.out)
    } 

    CLEAN_DATA(inputCsv)

    SORT_META_DATA(metadata, movements)

    LOCATIONS(cphlocs, counties)

    SPLIT_CLADES(CLEAN_DATA.out)

    SPLIT_CLADES.out.passSamples
        .flatMap()
        .map { file -> def key = file.name.toString().tokenize('_').get(0) 
        return tuple (key, file) 
        }
        .join(cladeInfo)
        .combine(outlierList)
        .set{ cladelists }
    
    FILTER_SAMPLES(cladelists)
    
    FILTER_SAMPLES.out.includedSamples
        .join(cladeInfo)
        .set { cladeSamples }

    FILTER_SAMPLES.out.includedSamples
        .combine(SORT_META_DATA.out)
        .set { cladeMeta }
    
    FILTER_SAMPLES.out.includedSamples
        .map { it[1] }
        .collectFile(name: 'filteredWgsMeta.csv', keepHeader: true)
        .set { filteredWgsMeta }

    FILTER_SAMPLES.out.excludedSamples
        .collectFile(name: 'highN.csv', keepHeader: true)
        .set { highNcount }

    EXCLUDED(CLEAN_DATA.out, highNcount, outlierList)
    
    CLADE_META_DATA(cladeMeta)

    CLADE_SNPS(cladeSamples)

    CLADE_MATRIX(CLADE_SNPS.out)

    CLADE_SNPS.out
        .combine(maxP200x)
        .combine(userMP)
        .set { megainput }

    GROW_TREES(megainput)

    GROW_TREES.out
        .join(cladeInfo)
        .join(CLADE_SNPS.out)
        .set { treedata }

    REFINE_TREES(treedata)

    REFINE_TREES.out
        .join(CLADE_META_DATA.out)
        .combine(LOCATIONS.out)
        .combine(auspiceconfig)
        .combine(colours)
        .set { exportData }

    JSON_EXPORT(exportData)

    METADATA_2_SQLITE(filteredWgsMeta, metadata, movements, cphlocs, EXCLUDED.out)
}