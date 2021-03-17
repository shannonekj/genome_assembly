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
### general info
sex = config['sex']
species_id = config['speciesID']
genome_size = config['genomesize']

### raw data
hifi_a = config['hifi_a']
hifi_b = config['hifi_b']
hifi_c = config['hifi_c']
tenx_r1 = config['tenx_r1']
tenx_r2 = config['tenx_r2']
hic_r1 = config['hic_r1']
hic_r2 = config['hic_r2']

### other file inputs
lg_loci = config['lg_loci']
lg_tsv = config['lg_tsv']

### software
salsa_path = config['salsa_path']
chrmnmr_path = config['chromonomer_path']

### parameters
#### salsa2
i = config['i']

#### arima
scratch_dir = config['scratch_dir']
map_quality = config['mapq']
cpu = config['cpu']

# other
prefix = species_id + '_' + sex



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
        echo file > {output}
        echo {input.tr1} >> {output}
        echo {input.tr2} >> {output}
        echo {input.hr1} >> {output}
        echo {input.hr2} >> {output}
        '''
                
rule fofn_long_reads:
    input:
        h1 = hifi_a,
        h2 = hifi_b,
        h3 = hifi_c,
    output:
        'input/long_reads_raw.fofn'
    shell: '''
        echo file > {output}
        echo {input.h1} >> {output}
        echo {input.h2} >> {output}
        echo {input.h3} >> {output}
        '''


