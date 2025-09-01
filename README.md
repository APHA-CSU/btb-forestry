# **bTB-forestry**

[![btb-forestry CI](https://github.com/APHA-CSU/btb-forestry/workflows/CI%20tests%20using%20nf-test/badge.svg)](https://github.com/APHA-CSU/btb-forestry/actions)

`bTB-forestry` is APHA's nextflow pipeline for analysing phylogenies and SNP matrices for bovine TB, on a clade-by-clade basis.  It is inteneded as a follow on process to [btb-seq](https://github.com/APHA-CSU/btb-seq)  and has been specifically designed around the outputs (summary csv and directory structure) from that pipeline.

Firstly, output csv files from multiple runs are concatenated, sorted, and where duplicate samples (or submissons) exist, only the highest quality one is retained.  Lists of 'Pass' samples for each clade are generated, and consensus fasta files concatenated, prior to extracting polymorphic sites (SNPs) with [snp-sites](https://github.com/sanger-pathogens/snp-sites).  Pairwise SNP distance matrices are calculated with [snp-dists](https://github.com/tseemann/snp-dists).  Maximum parsimony phylogenetic trees are generated with [Megacc](https://www.megasoftware.net/).

Finally, the pipeline formats trees correctly and extracts information in json format to allow display via [Nextstrain](https://docs.nextstrain.org/en/latest/index.html).

__Quick start__
To run the pipeline with default settings:

`nextflow run APHA-CSU/btb-forestry`

Or with custom parameters:

`nextflow run APHA-CSU/btb-forestry \
    --pathTocsv "/path/to/btb-seq/results/**/*FinalOut*.csv" \
    --metadata "/path/to/metadata.csv" \
    --outdir "/path/to/output"`

__Pipeline Overview__

The pipeline processes data through the following key stages:

1)  Data Preparation: Concatenates and cleans output CSV files from btb-seq runs
2)  Quality Filtering: Removes duplicates, retaining highest quality samples per submission
3)  Clade Separation: Splits samples by WGS cluster/clade for independent analysis
4)  SNP Analysis: Extracts polymorphic sites and calculates pairwise SNP distances
5)  Phylogeny: Generates maximum parsimony trees using MEGA
6)  Visualisation: Formats output for Nextstrain display

flowchart TD
    A[btb-seq CSV Files] --> B[CLEAN_DATA]
    B --> C[SPLIT_CLADES]
    C --> D[FILTER_SAMPLES]
    D --> E[CLADE_SNPS]
    E --> F[CLADE_MATRIX]
    E --> G[GROW_TREES]
    G --> H[REFINE_TREES]
    H --> I[JSON_EXPORT]
    I --> J[Nextstrain Visualization]
    D --> K[METADATA_2_SQLITE]

__Parameters__

_Required Input Files_
--pathTocsv: Path pattern to btb-seq FinalOut CSV files (default: ${PWD}/**/*FinalOut*.csv)
--metadata: Sample metadata CSV file (default: ${PWD}/metadata.csv)
--movements: Cattle movement data CSV (default: ${PWD}/movements.csv)
--locations: Location data CSV (default: ${PWD}/locations.csv)

_Output Options_
--outdir: Output directory (default: current working directory)
--today: Date string for output naming (default: current date as ddMMMYY)
--prod_run: Production mode - backs up existing data (default: false)
--matrixdir: Directory for SNP matrix backup (default: ${PWD}/matrixcopy)

_Configuration Files_
--auspiceconfig: Auspice configuration JSON for Nextstrain
--colours: Custom color scheme for visualization
--counties: Geographic county mapping
--outliers: List of samples to exclude from analysis
--cladeinfo: Clade-specific analysis parameters
Analysis Parameters
--maxP200x: MEGA analysis options for 200x bootstrap MP trees
--userMP: MEGA analysis options for user-defined MP trees

__Dependencies__
The pipeline requires:

-   Nextflow (DSL2)
-   snp-sites - SNP extraction
-   snp-dists - Distance matrix calculation
-   MEGA - Phylogenetic tree construction
-   Python 3 with required packages for data processing

__Help__
For detailed parameter information:

__Integration with btb-seq__
This pipeline is designed to work seamlessly with outputs from the btb-seq pipeline. The expected input is the FinalOut.csv summary files that contain sample outcomes, WGS clusters (clades), and quality metrics.

__Validation and Testing__
The pipeline includes automated testing via GitHub Actions to ensure reliability and reproducibility of phylogenetic analyses across different bovine TB clades.