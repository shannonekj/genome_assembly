#!/usr/bin/env python3
# File   : Snakefile
# Author : Shannon Joslin <sejoslin@ucdavis.edu>
# Date   : 2020.11.10

##############
##  CONFIG  ##
##############

# override this with --configfile on command line
configfile: 'docs/conf_data.yml'
## need to add cluster config to the conf_data_slurm.yml file...can make another for local... conf_data_local.yml

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

# lists
seq_tech_links = {"tenxR1": "path/to/raw/data",
                  "tenxR2": "path/to/raw/dat",
                  "pacbio": "path/to/raw/dat",
                  "hicR1": "path/to/raw/dat",
                  "hicR2": "path/to/raw/dat"}

TECHNOLOGIES = seq_tech_links.keys()



# r00lz

rule all:
    input:
        'inputs/02-hicanu/' + species_id + '.contigs.fasta',
        'outputs/reports_raw_data/katHist_{params.prefix}_{params.tnx}_k{params.kmer}'

rule make_symlink:
    output: 

rule sym_link:
    input:
        tnxR1 = tenx_r1,
        tnxR2 = tenx_r2,
        pcbBM = hifi_file,
        hicR1 = HIC_r1,
        hicR2 = HIC_r2
    output:
        tnxR1 = 'inputs/00-raw/' + species_id + '_tnx_R1.fq.gz',
        tnxR2 = 'inputs/00-raw/' + species_id + '_tnx_R2.fq.gz',
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
        pcbCCS = 'inputs/01-ccs/' + species_id + '_pcb_hf_ccs.bam'
    conda: 'envs/hicanu.yml'
    params:
        prefix = species_id,
        thread = '48'
    shell:'''
        ccs --chunk 1/1 -j {params.thread} --log-level INFO --log-file all.log --report-file {params.prefix}_ccs_report.txt {input.pcbBM} {params.prefix}_pcb_hf_ccs.fastq.gz
    '''

rule qc_kat_hist:
    input:
        tnx_r1 = 'inputs/00-raw/' + species_id + '_tnx_R1.fq.gz',
        tnx_r2 = 'inputs/00-raw/' + species_id + '_tnx_R2.fq.gz',
        hic_r1 = 'inputs/00-raw/' + species_id + '_hic_R1.fq.gz',
        hic_r2 = 'inputs/00-raw/' + species_id + '_hic_R2.fq.gz'
    output:
        'outputs/reports_raw_data/katHist_{params.prefix}_{params.tnx}_k{params.kmer}'
    conda: 'kat.yml'
    params:
        kmer = '31',
        prefix = species_id,
        thread = '4',
        tnx = '10X',
        hic = 'hic'
    shell:'''
        kat hist -o katHist_{params.prefix}_{params.tnx}_k{params.kmer} -m {params.kmer} -t {params.thread} {input.tnx_r1} {input.tnx_r2}
        kat hist -o katHist_{params.prefix}_{params.hic}_k{params.kmer} -m {params.kmer} -t {params.thread} {input.hic_r1} {input.hic_r2}
    '''

rule qc_kat_gcp:
    input:
        'inputs/00-raw/{sample}.fq.gz'

rule qc_kat_comp:
    input:
        'inputs/00-raw/{sample}.fq.gz'

rule qc_pacbio:
    input:
        'ccs.bam'
    output:
        'ccs_report.txt'

rule run_hicanu:
    input:
        pcbCCS = 'inputs/01-ccs/' + species_id + '_pcb_hf_ccs.bam'
    output:
        asm_hc = 'inputs/02-hicanu/' + species_id + '.contigs.fasta'
    params:
        prefix = species_id,
        g = genomesize
    conda: 'envs/hicanu.yml'
    shell:'''
        canu  -p {params.prefix} -d inputs/01-hicanu genomeSize={params.g}m -useGrid=true -gridOptions="--time=96:00:00 -p bigmemh" -pacbio-hifi {output.asm_hc}
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
