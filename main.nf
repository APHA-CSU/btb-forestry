#!/usr/bin/env nextflow
nextflow.enable.dsl=2
    
// Default values for required parameters
params.pathTocsv = "${env('PWD')}/**/*FinalOut*.csv"
params.metadata = "${env('PWD')}/metadata.csv"
params.movements = "${env('PWD')}/movements.csv"
params.locations = "${env('PWD')}/locations.csv"
params.auspiceconfig = "$projectDir/accessory/auspice_config.json"
params.colours = "$projectDir/accessory/custom-colours.tsv"
params.counties = "$projectDir/accessory/counties.tsv"
params.outliers = "$projectDir/accessory/outliers.txt"
params.cladeinfo = "$projectDir/accessory/CladeInfo.csv"
params.today = new Date().format('ddMMMYY')
params.outdir = "${env('PWD')}"
params.homedir = "${env('HOME')}"
params.prod_run = false
params.matrixdir = "${env('PWD')}/matrixcopy"
params.help = false
params.commitId = null

// Location of megacc analysis options (.mao) files 
params.maxP200x = "$projectDir/accessory/infer_MP_nucleotide_200x.mao"
params.userMP = "$projectDir/accessory/analyze_user_tree_MP__nucleotide.mao"

// Derived params so modules can read them
params.publishDir = params.prod_run
  ? "${params.outdir}/btb-forest_prod/"
  : "${params.outdir}/btb-forest_${params.today}/"

params.matrixCopy = "${params.matrixdir}/SNP_matrix_${params.today}/"

/* Print help message if --help is passed */
workflow help {
  if (params.help){
    println """
    btb-forestry - Bovine TB Phylogenetic Analysis Workflow
    
    Usage:
        nextflow run main.nf [options]
    
    Options:
      --pathTocsv              Path to CSV files produced by btb-seq (default: ${params.pathTocsv})
      --metadata               Path to metadata CSV file (default: ${params.metadata})
      --movements              Path to movements CSV file (default: ${params.movements})
      --locations              Path to locations CSV file (default: ${params.locations})
      --outdir                 Output directory (default: ${params.outdir})
      --homedir                Home directory (default: ${params.homedir})
      --today                  Date string for output naming (default: ${params.today})
      --prod_run               Production run mode - backs up existing data (default: ${params.prod_run})
      --matrixdir              Directory for matrix copy (default: ${params.matrixdir})
      --outliers               Path to outliers file (default: ${params.outliers})
      --cladeinfo              Path to clade information CSV (default: ${params.cladeinfo})
      --auspiceconfig          Auspice configuration JSON (default: ${params.auspiceconfig})
      --colours                Custom colours TSV file (default: ${params.colours})
      --counties               Counties TSV file (default: ${params.counties})
      --maxP200x               MEGA analysis options file for MP 200x (default: ${params.maxP200x})
      --userMP                 MEGA analysis options file for user MP tree (default: ${params.userMP})
      --help                   Print this help message
    
    Examples:
        nextflow run main.nf --pathTocsv "/data/**/*Results*.csv" 
    """
    exit 0
  }
}
      
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

/* define workflow */
workflow btb_forestry {
    main:
    
    ch_csv = Channel
        .fromPath( params.pathTocsv )
        .collectFile(name: 'All_FinalOut.csv', keepHeader: true, newLine: true)

    ch_info = Channel.fromPath( params.cladeinfo )
        .splitCsv(header:true)
        .map { row-> tuple(row.clade, row.maxN, row.outgroup, row.outgroupLoc) }

    if( params.prod_run ){
        BACKUP_PROD_DATA(params.outdir)
        FORESTRY_META_DATA(BACKUP_PROD_DATA.out, params.today)
    } 

    CLEAN_DATA(
        ch_csv,
        params.today
        )

    SORT_META_DATA(
        params.metadata,
        params.movements,
        params.today
        )

    LOCATIONS(
        params.locations, 
        params.counties,
        params.today
        )

    SPLIT_CLADES(
        CLEAN_DATA.out
        )

    FILTER_SAMPLES(
        SPLIT_CLADES.out.passSamples
        .flatMap()
        .map { file -> def key = file.name.toString().tokenize('_').get(0) 
        return tuple (key, file) 
        }
        .join(ch_info),
        params.outliers,
        params.today
        )

    EXCLUDED(
        CLEAN_DATA.out, 
        FILTER_SAMPLES.out.excludedSamples
        .collectFile(name: 'highN.csv', keepHeader: true), 
        params.outliers,
        params.today
        )
    
    CLADE_META_DATA(
        FILTER_SAMPLES.out.includedSamples
        .combine(SORT_META_DATA.out),
        params.today
        )

    CLADE_SNPS(
        FILTER_SAMPLES.out.includedSamples
        .join(ch_info),
        params.today
        )

    CLADE_MATRIX(
        CLADE_SNPS.out,
        params.today
        )

    GROW_TREES(
        CLADE_SNPS.out,
        params.maxP200x,
        params.userMP,
        params.today
        )

    REFINE_TREES(
        GROW_TREES.out
        .join(ch_info)
        .join(CLADE_SNPS.out),
        params.today
        )

    JSON_EXPORT(
        REFINE_TREES.out
        .join(CLADE_META_DATA.out)
        .combine(LOCATIONS.out),
        params.auspiceconfig,
        params.colours,
        params.today
        )

    METADATA_2_SQLITE(
        FILTER_SAMPLES.out.includedSamples
        .map { it[1] }
        .collectFile(name: 'filteredWgsMeta.csv', keepHeader: true), 
        params.metadata, 
        params.movements, 
        params.locations, 
        EXCLUDED.out)
}

workflow {
    help ()
    btb_forestry()
}