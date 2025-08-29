process CLADE_SNPS {
    errorStrategy 'retry'
    maxRetries 2
    maxForks 6
    tag "$clade"
    publishDir "$params.publishDir/snp-fasta/", mode: 'copy', pattern: '*_snp-only.fas'

    input:
        tuple val (clade), path (cladelst), val (maxN), val (outGroup), val (outGroupLoc)
        val (today)

    output:
        tuple val (clade), path ("${clade}_${today}_snp-only.fas")

    script:
    """
    #!/bin/bash
    set -eo pipefail
    
    # Collects and concatenates all consensus fasta files in the given input list
    # (from s3).
    # snp-sites (https://github.com/sanger-pathogens/snp-sites) is then run to 
    # generate snp-only fasta files.  Intermediary files are removed to save disk
    # space 

    while IFS=, read -r Submission Sample GenomeCov MeanDepth pcMapped group Ncount Path;
    do
        aws s3 cp "\${Path}consensus/\${Sample}_consensus.fas" "\${Sample}_consensus.fas";
    done < <(tail -n +2 $cladelst)

    # Add outgroup fasta (outgroup is predetermined for each clade)
    aws s3 cp "${outGroupLoc}consensus/${outGroup}_consensus.fas" "${outGroup}_consensus.fas"

    cat *_consensus.fas > ${clade}_AllConsensus.fas
    rm *_consensus.fas
    snp-sites -c -o ${clade}_${today}_snp-only.fas ${clade}_AllConsensus.fas
    rm *_AllConsensus.fas
    """
}