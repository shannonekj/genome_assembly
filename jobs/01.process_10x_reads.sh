#!/bin/bash
#
#SBATCH --array=1-2
#SBATCH -J proc10x
#SBATCH -e slurm/01.process_10x_reads.j%j.err
#SBATCH -o slurm/01.process_10x_reads.j%j.out
#SBATCH --mem=90000
#SBATCH --time=03-04
#SBATCH -p bigmemh


###############
###  SETUP  ###
###############

set -e
set -x

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"
THREADS=${SLURM_NTASKS}
echo "Threads: $THREADS"
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1024)
echo "Mem: ${MEM}Gb"

# variables
sex=(M F)
x=${SLURM_ARRAY_TASK_ID}
echo "x is ${x}"
s=${sex[$(( $x - 1 ))]}
echo "Processing reads for ${s}"
species="Hyp_tra"
out_prefix="${species}_${s}"

# directories
data_dir="/group/millermrgrp2/shannon/projects/assembly_genome_Hypomesus-transpacificus/00-raw_data/data-10X_${s}"
out_dir="/group/millermrgrp2/shannon/projects/assembly_genome_Hypomesus-transpacificus/01-filtered_data/data-10X_${s}"
git_dir="/home/sejoslin/git_repos/genome_assembly"
proc_10x_dir="${git_dir}/scripts/proc10xG"

# files
fastq1="${data_dir}/*R1_001.fastq.gz"
fastq2="${data_dir}/*R2_001.fastq.gz"

###################
###  DO THINGS  ###
###################

mkdir -p ${out_dir}
cd ${out_dir}

[ -d $proc_10x_dir ] || git clone https://github.com/shannonekj/proc10xG.git ${proc_10x_dir}

call="${proc_10x_dir}/process_10xReads.py \
 -1 ${fastq1} \
 -2 ${fastq2} \
 -o ${out_prefix} -a"

echo ${call}
eval ${call}



end=`date +%s`
