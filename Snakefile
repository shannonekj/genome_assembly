#!/usr/bin/env python3
# File   : Snakefile
# Author : Shannon Joslin <sejoslin@ucdavis.edu>
# Date   : 2020.11.09

##############
##  CONFIG  ##
##############

# override this with --configfile on command line
configfile: 'docs/conf_data.yml'

# general info
sex = config['sex']
species_id = config['speciesID']
genomesize = config['genomesize']
n_pcb_runs = config['number_of_pcb_runs']

# inputs
## data
hifi_file = config['hifi']
tenx_r1 = config['tenx_r1']
tenx_r2 = config['tenx_r2']
HIC_r1 = config['hic_r1']
HIC_r2 = config['hic_r2']



# r00lz

#rule all:
#    input:
#        "symlinked files"

rule sym_link:
    input:
        tnxR1 = tenx_r1,
        tnxR2 = tenx_r2,
        pcbBM = hifi_file,
        hicR1 = HIC_r1,
        hicR2 = HIC_r2
    output:
        tnxR1 = 'inputs/00-raw/' + species_id + '_tnx_R1.fq.gz',
        tnxR2 = 'inputs/00-raw' + species_id + '_tnx_R2.fq.gz',
        pcbBM = 'inputs/00-raw/' + species_id + '_pcb_hf.bam',
        hicR1 = 'inputs/00-raw/' + species_id + '_hic_R1.fq.gz',
        hicR2 = 'inputs/00-raw/' + species_id + '_hic_R2.fq.gz'
    shell:'''
        ln -s {input.tnxR1} {output.tnxR1}
        ln -s {input.tnxR2} {output.tnxR2}
        ln -s {input.pcbBM} {output.pcbBM}
        ln -s {input.hicR1} {output.hicR1}
        ln -s {input.hicR2} {output.hicR2}
    '''

rule get_ccs:
    input:
        pcbBM = 'inputs/00-raw/' + species_id + '_pcb_hf.bam'
    output:
        pcbCCS = 'inputs/00-raw/' + species_id + '_pcb_hf_ccs.bam'
    conda: 'envs/ccs.yml'
    shell:'''
        ccs BLAH BALH
    '''

rule run_hicanu:
    input:
        prefix = species_id
        g = genomesize
        pcbCCS = 'inputs/00-raw/' + species_id + '_pcb_hf_ccs.bam'
    output:
        asm_hc = 'inputs/01-hicanu/' + species_id + '.contigs.fasta'
    conda: 'envs/hicanu.yml'
    shell:'''
        canu  -p {input.prefix} -d inputs/01-hicanu genomeSize={input.g}m -useGrid=true -gridOptions="--time=96:00:00 -p bigmemh" -pacbio-hifi {output.asm_hc}
    '''


# PLAN

# symlink raw data to local input dir
## hifi
## tenx
## hic

# steps
## subread to ccs
## qc raw

## hicanu
### run
### qc
#### busco
#### seqstats

## purge dups
### run_step1a
### run_step1b
### run_step2
### run_step3
### qc
#### busco
#### seqstats

## scaff10x
### debarcode
### mkref
### run
### qc
#### busco
#### seqstats

## salsa2
### arima mapping
### format
### run
### qc

## overall report
