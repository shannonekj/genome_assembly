#!/bin/bash -login
#SBATCH -p high
#SBATCH -J smk
#SBATCH -o jobs/slurm/snakemake.j%j.out
#SBATCH -e jobs/slurm/snakemake.j%j.err
#SBATCH -c 8
#SBATCH -t 01-0:30:00
#SBATCH --mem=24gb

# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh

# activate your desired conda environment
conda activate snakemake

cd $SLURM_SUBMIT_DIR

set -o nounset
set -o errexit
set -x

snakemake -p -j 8 --use-conda -s raw_stats_F.snakefile

env | grep SLURM 

scontrol show job ${SLURM_JOB_ID}  

sstat --format 'JobID,MaxRSS,AveCPU' -P ${SLURM_JOB_ID}.batch
