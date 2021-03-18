#!/usr/bin/env python3
# File   : Snakefile.prep (run first)
# Author : Shannon Joslin <sejoslin@ucdavis.edu>
# Date   : 2021.03.17
# Use    : Makes tab separated input files for usage with Snakefile.asm
# Data types:
#   -PacBio HiFi
#   -10X Genomics linked reads (illumina)
#   -Phase hic (illumina)
#   -linkage map (Lew et al. 2015)


##############
##  CONFIG  ##
##############
# python stuff
import pandas as pd

# override this with --configfile option of snakemake on command line
configfile: 'docs/conf_data_F.yml'

## load in
### raw data
hifi_a = config['hifi_a']
hifi_b = config['hifi_b']
hifi_c = config['hifi_c']
tenx_r1 = config['tenx_r1']
tenx_r2 = config['tenx_r2']
hic_r1 = config['hic_r1']
hic_r2 = config['hic_r2']



###############
###  r00lz  ###
###############
rule all_prep:
    input:
        'input/shrt_reads_raw.fofn',
        'input/long_reads_raw.fofn'


rule fofn_short_reads:
    input:
        tr1 = tenx_r1,
        tr2 = tenx_r2,
        hr1 = hic_r1,
        hr2 = hic_r2,
    output:
        'input/shrt_reads_raw.fofn'
    shell: '''
        echo -e file'\t'sample'\t'name > {output}
        name=$(echo {input.tr1} | rev | cut -f1 -d/ | rev)
        echo {input.tr1}'\t'$name'\t'tnx_R1 >> {output}
        name=$(echo {input.tr2} | rev | cut -f1 -d/ | rev)
        echo {input.tr2}'\t'$name'\t'tnx_R2 >> {output}
        name=$(echo {input.hr1} | rev | cut -f1 -d/ | rev)
        echo {input.hr1}'\t'$name'\t'hic_R1 >> {output}
        name=$(echo {input.hr2} | rev | cut -f1 -d/ | rev)
        echo {input.hr2}'\t'$name'\t'hic_R2 >> {output}
        '''
                
rule fofn_long_reads:
    input:
        h1 = hifi_a,
        h2 = hifi_b,
        h3 = hifi_c,
    output:
        'input/long_reads_raw.fofn'
    shell: '''
        echo -e file'\t'sample'\t'name > {output}
        name=$(echo {input.h1} | rev | cut -f1 -d/ | rev)
        echo {input.h1}'\t'$name'\t'pcb_1 >> {output}
        name=$(echo {input.h2} | rev | cut -f1 -d/ | rev)
        echo {input.h2}'\t'$name'\t'pcb_2 >> {output}
        name=$(echo {input.h3} | rev | cut -f1 -d/ | rev)
        echo {input.h3}'\t'$name'\t'pcb_3 >> {output}
        '''


