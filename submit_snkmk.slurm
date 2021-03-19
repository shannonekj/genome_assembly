#!/bin/bash -login
#SBATCH -p bigmemh
#SBATCH -J smk
#SBATCH -o jobs/slurm/snakemake.j%j.kat_stats.out
#SBATCH -e jobs/slurm/snakemake.j%j.kat_stats.err
#SBATCH -c 24
#SBATCH -t 03-06:12:24
#SBATCH --mem=256gb

# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh

# activate your desired conda environment
conda activate snakemake

cd $SLURM_SUBMIT_DIR

set -o nounset
set -o errexit
set -x

echo ""
echo "Running snakefile" $(date +%D' '%T)
snakemake -p -j 8 --use-conda -s raw_stats_F.snakefile
echo "    Complete!" $(date +%D' '%T)
echo ""

env | grep SLURM 

scontrol show job ${SLURM_JOB_ID}  

sstat --format 'JobID,MaxRSS,AveCPU' -P ${SLURM_JOB_ID}.batch
