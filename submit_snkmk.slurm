#!/bin/bash -login
#SBATCH -p high
#SBATCH -J runsmk
#SBATCH -o jobs/slurm/snakemake.j%j.kat_stats.out
#SBATCH -e jobs/slurm/snakemake.j%j.kat_stats.err
#SBATCH --ntasks=1
#SBATCH -c 1
#SBATCH -t 64:16:32
#SBATCH --mem=2Gb

# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh

# activate your desired conda environment
conda activate snakemake

cd $SLURM_SUBMIT_DIR

set -o nounset
set -o errexit
set -x

echo ""
echo "Running snakefile using $SLURM_CPUS_PER_TASK threads" $(date +%D' '%T)
snakemake --cluster "sbatch -t {cluster.time} -p {cluster.partition} -N {cluster.nodes} -n {cluster.ntasks} --mem={cluster.memory} -e {cluster.error} -o {cluster.output}" --cluster-config docs/farm_config.yml --jobs 1 --latency-wait=30 --use-conda --keep-going -s raw_stats.snakefile
#snakemake -p -j $SLURM_CPUS_PER_TASK --use-conda -s raw_stats_F.snakefile 
echo "    Complete!" $(date +%D' '%T)
echo ""

env | grep SLURM 

scontrol show job ${SLURM_JOB_ID}  

sstat --format 'JobID,MaxRSS,AveCPU' -P ${SLURM_JOB_ID}.batch
