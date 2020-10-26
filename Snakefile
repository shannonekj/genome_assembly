# override this with --configfile on command line
configfile: 'docs/conf_data.yml'

### config stuff loaded from config file
sequence_data_dir = config['sequence_data_dir'].rstrip('/')

# inputs
## data
hifi_dir
hifi_file
tenx_dir
tenx_r1
tenx_r2
hic_dir
hic_r1
hic_r2

# r00lz

rule all:
    input:
        "file"

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
