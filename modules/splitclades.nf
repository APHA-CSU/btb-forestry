process SPLIT_CLADES {

    input:
        path clean

    output:
        path('B*_Pass.csv'), emit: passSamples

    script:
    """
    #!/bin/bash
    set -eo pipefail

    # Separate sample list based on clade and outcome
    awk -F, '{print >> (\$9"_"\$7".csv")}' ${clean}
    """
}