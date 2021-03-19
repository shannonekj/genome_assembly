#!/bin/bash -login
#SBATCH -p high
#SBATCH -J smk
#SBATCH -o jobs/slurm/snakemake.j%j.test.out
#SBATCH -e jobs/slurm/snakemake.j%j.test.err
#SBATCH -c 10
#SBATCH -t 00:30:00
#SBATCH --mem=2gb

# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh

# activate your desired conda environment
conda activate snakemake

cd $SLURM_SUBMIT_DIR
echo "Using $SLURM_CPUS_PER_TASK cpu's"

set -o nounset
set -o errexit
set -x

snakemake -p -n -j $SLURM_CPUS_PER_TASK --use-conda -s raw_stats_F.snakefile

env | grep SLURM 

scontrol show job ${SLURM_JOB_ID}  

sstat --format 'JobID,MaxRSS,AveCPU' -P ${SLURM_JOB_ID}.batch
