# **bTB-forestry**

[![btb-forestry CI](https://github.com/APHA-CSU/btb-forestry/workflows/btb-forestry%20CI/badge.svg)](https://github.com/APHA-CSU/btb-forestry/actions)

`bTB-forestry` is APHA's nextflow pipeline for analysing phylogenies and SNP matrices for bovine TB, on a clade-by-clade basis.  It is inteneded as a follow on process to [btb-seq](https://github.com/APHA-CSU/btb-seq) and has been specifically designed around the outputs (summary csv and directory structure) from that pipeline. The outputs of btb-forestry are intended for use in [ViewBovis](https://github.com/APHA-CSU/ViewBovis).

**Quick start**

To run the pipeline with default settings:

```
nextflow run APHA-CSU/btb-forestry -with-docker aphacsubot/btb-forestry
```

Or with custom parameters:

```
nextflow run APHA-CSU/btb-forestry -with-docker aphacsubot/btb-forestry \
    --pathTocsv "/path/to/btb-seq/results/**/*FinalOut*.csv" \
    --metadata "/path/to/metadata.csv" \
    --movements='/path/to/movements.csv' \
    --locations='/path/to/locations.csv'
```

**Pipeline overview**

```mermaid
flowchart TD
    %% Input files
    subgraph inputs ["Input Files"]
        direction TB
        subgraph btb ["btb-seq Output"]
            AA[CSV 1]
            AB[CSV 2] 
            AC[CSV ...]
        end
        subgraph meta ["Metadata Files"]
            C[Metadata]
            E[Locations]
            G[Counties]
            U[Movements]
        end
    end
    
    %% Data preparation
    subgraph prep ["Data Preparation"]
        direction TB
        BA[COMBINE_CSV]
        B[CLEAN_DATA]
        D[SORT_META_DATA]
        F[LOCATIONS]
    end
    
    %% Core analysis
    subgraph analysis ["Core Analysis"]
        direction TB
        K[SPLIT_CLADES]
        L[FILTER_SAMPLES]
        M[EXCLUDED]
        N[CLADE_META_DATA]
        O[CLADE_SNPS]
    end
    
    %% Phylogenetic analysis
    subgraph phylo ["Phylogenetic Analysis"]
        direction TB
        P[CLADE_MATRIX]
        Q[GROW_TREES]
        R[REFINE_TREES]
    end
    
    %% Output
    subgraph output ["Output"]
        direction TB
        S[JSON_EXPORT]
        T[METADATA_2_SQLITE]
        V[ViewBovis]
    end
    
    %% Vertical flow connections
    inputs --> prep
    prep --> analysis
    analysis --> phylo
    phylo --> output
    
    %% Specific connections
    AA --> BA
    AB --> BA
    AC --> BA
    BA --> B
    C --> D
    E --> F
    G --> F
    
    B --> K
    K --> L
    L --> M
    B --> M
    L --> N
    D --> N
    L --> O
    
    O --> P
    O --> Q
    Q --> R
    
    R --> S
    N --> S
    F --> S
    L --> T
    C --> T
    U --> T
    E --> T
    M --> T
    
    S --> V
    T --> V
```

**Parameters**

btb-forestry - Bovine TB Phylogenetic Analysis Workflow

```
Usage:
    nextflow run main.nf [options]

Options:
  --pathTocsv              Path to CSV files produced by btb-seq (default: /home/user/git/btb-forestry/**/*FinalOut*.csv)
  --metadata               Path to metadata CSV file (default: /home/user/git/btb-forestry/metadata.csv)
  --movements              Path to movements CSV file (default: /home/user/git/btb-forestry/movements.csv)
  --locations              Path to locations CSV file (default: /home/user/git/btb-forestry/locations.csv)
  --outdir                 Output directory (default: /home/user/git/btb-forestry)
  --homedir                Home directory (default: /home/guyoldrieve)
  --today                  Date string for output naming (default: 01Sep25)
  --prod_run               Production run mode - backs up existing data (default: false)
  --matrixdir              Directory for matrix copy (default: /home/user/git/btb-forestry/matrixcopy)
  --outliers               Path to outliers file (default: /home/user/git/btb-forestry/accessory/outliers.txt)
  --cladeinfo              Path to clade information CSV (default: /home/user/git/btb-forestry/accessory/CladeInfo.csv)
  --auspiceconfig          Auspice configuration JSON (default: /home/user/git/btb-forestry/accessory/auspice_config.json)
  --colours                Custom colours TSV file (default: /home/user/git/btb-forestry/accessory/custom-colours.tsv)
  --counties               Counties TSV file (default: /home/user/git/btb-forestry/accessory/counties.tsv)
  --maxP200x               MEGA analysis options file for MP 200x (default: /home/user/git/btb-forestry/accessory/infer_MP_nucleotide_200x.mao)
  --userMP                 MEGA analysis options file for user MP tree (default: /home/user/git/btb-forestry/accessory/analyze_user_tree_MP__nucleotide.mao)
  --help                   Print this help message

Examples:
    nextflow run main.nf --pathTocsv "/data/**/*Results*.csv"
```

**Dependencies**

The pipeline requires:

-   Nextflow (DSL2)
-   [snp-sites](https://github.com/sanger-pathogens/snp-sites) - SNP extraction
-   [snp-dists](https://github.com/tseemann/snp-dists) - Distance matrix calculation
-   [Megacc](https://www.megasoftware.net/) - Phylogenetic tree construction
-   Python 3 with required packages for data processing

**Integration with btb-seq**

This pipeline is designed to work seamlessly with outputs from the btb-seq pipeline. The expected input is the FinalOut.csv summary files that contain sample outcomes, WGS clusters (clades), and quality metrics. btb-forestry outputs are formatted for display in ViewBovis/NextStrain.

**Validation and testing**

The pipeline includes automated testing with nf-test via GitHub Actions to ensure reliability and reproducibility of phylogenetic analyses across different bovine TB clades.