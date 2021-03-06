# **bTB-forestry**

`bTB-forestry` is APHA's nextflow pipeline for analysing phylogenies and SNP matrices for bovine TB, on a clade-by-clade basis.  It is inteneded as a follow on process to [btb-seq](https://github.com/APHA-CSU/btb-seq)  and has been specifically designed around the outputs (summary csv and directory structure) from that pipeline.

Firstly, output csv files from multiple runs are concatenated, sorted, and where duplicate samples (or submissons) exist, only the highest quality one is retained.  Lists of 'Pass' samples for each clade are generated, and consensus fasta files concatenated, prior to extracting polymorphic sites (SNPs) with [snp-sites](https://github.com/sanger-pathogens/snp-sites).  Pairwise SNP distance matrices are calculated with [snp-dists](https://github.com/tseemann/snp-dists).  Finally, maximum parsimony phylogenetic trees are generated with [Megacc](https://www.megasoftware.net/).
