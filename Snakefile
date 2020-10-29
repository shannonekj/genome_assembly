#!/usr/bin/env python3
# File   : Snakefile
# Author : Shannon Joslin <sejoslin@ucdavis.edu>
# Date   : 2020.10.26

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
hic_r1 = config['hic_r1']
hic_r2 = config['hic_r2']

# r00lz

rule all:
    input:
        "symlinked files"

rule sym_link:
    input:
        "raw files"
    output:
        "symlinked files"



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
