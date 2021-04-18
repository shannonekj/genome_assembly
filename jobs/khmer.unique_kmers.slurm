#!/bin/bash
#SBATCH -J gcp_41
#SBATCH -e slurm/j%j.khmer.unique_kmers.err
#SBATCH -o slurm/j%j.khmer.unique_kmers.out
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=MaxMemPerNode
#SBATCH --time=02-12
#SBATCH -p bigmemm


# conda
echo "Loading environment."
# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh
conda activate kat

set -e
set -x

infiles=("/home/sejoslin/git_repos/genome_assembly/input/data/raw/F_tnx_R1.fastq.gz" "/home/sejoslin/git_repos/genome_assembly/input/data/raw/F_tnx_R2.fastq.gz")
threads=${SLURM_NTASKS}

out_dir="/home/sejoslin/git_repos/genome_assembly/output/kat_rawi/khmer"
mkdir -p ${out_dir}
cd ${out_dir}

call="unique-kmers.py -k 41 -R F_tnx_k41 /home/sejoslin/git_repos/genome_assembly/input/data/raw/F_tnx_R{1,2}.fastq.gz"
echo ${call}
eval ${call}

sstat --format 'JobID,MaxRSS,AveCPU' -P ${SLURM_JOB_ID}.batch
