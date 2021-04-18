#!/bin/bash
# Author : Shannon E.K. Joslin
# File : longqc_stats.sh
# Usage : bash longqc_stats.sh <out_dir> <in_fastq> <longqc_dir>
# Date : 11 April 2021

# NOTE: Be certain to have conda env with appropriate dependencies setup.

###############
###  SETUP  ###
###############
hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"
THREADS=${SLURM_NTASKS}
echo "Threads: $THREADS"
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1024)
echo "Mem: $MEM"

###  Conda ###
echo "Loading environment."
# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh
conda activate lqc

###  Variables  ###
echo "Setting up variables"

# external
OUT_DIR=$1      # directory specific to whatever seq file you are genereating output for
FASTQ=$2        # seq file w CCS data above Q20
LQC_DIR=$3      # directory that houses longQC.py software
THREADS=$4      # number of threads to use


#################
###  LONG QC  ###
#################

echo "Making output directory"
mkdir -p ${OUT_DIR}
cd ${OUT_DIR}

# run longqc
echo "Running LongQC"
python ${LQC_DIR}/longQC.py sampleqc -x pb-hifi -m 1 -p ${THREADS} -o ${OUT_DIR} ${FASTQ}
echo "    Complete!"

