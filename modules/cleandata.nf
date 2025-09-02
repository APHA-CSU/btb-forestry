process CLEAN_DATA {
    publishDir "$params.publishDir", mode: 'copy', pattern: 'bTB_Allclean_*.csv'
    
    input:
        path concat_csv
        val today
        
    output:
        path ('bTB_Allclean_*.csv')
    
    script:
    """
    #!/bin/bash
    set -eo pipefail

    # Add submission numbers
    while IFS= read -r line;
    do
        sample=\$(echo "\$line" | awk -F, '/[A-Z]*-*[0-9]{2,2}-[0-9]{4,5}-[0-9]{2,2}*/ {print \$1}');
        if [[ -z \$sample ]];
            then subno=\$(echo "\$line" | awk -F, '{print \$1}');
            else
                IFS=-, read -r -a array <<< \$sample
                if [[ \${array[0]} = [A-Z]* ]]; 
                    then fivedig=\$(echo "\${array[2]}" | sed 's/\\b[0-9]\\{4\\}\\b/0&/1')
                        year=\$(echo \${array[3]} | sed 's/^\\(.\\{2\\}\\).*\$/\\1/')
                        subno=\$(echo AF-\${array[1]}-\$fivedig-\$year); 
                    else fivedig=\$(echo "\${array[1]}" | sed 's/\\b[0-9]\\{4\\}\\b/0&/1')
                        year=\$(echo \${array[2]} | sed 's/^\\(.\\{2\\}\\).*\$/\\1/')
                        subno=\$(echo AF-\${array[0]}-\$fivedig-\$year);
                fi
            fi
        echo -e "\$subno,\$line" >> withsub.csv
        
    done < ${concat_csv}
    
    # Clean and remove duplicates
    head -n 1 withsub.csv > bTB_Allclean_${today}.csv && tail -n +2 withsub.csv | \\
        (sort -t ',' -k1,1 -n -k15,15 | \\
        sort -u -t ',' -k1,1 | \\
        sed '/^#/d') >> bTB_Allclean_${today}.csv
    """
}