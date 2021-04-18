#!/bin/bash
#SBATCH -J hist_41
#SBATCH -e slurm/j%j.manual_run_kat_hist_k41.err
#SBATCH -o slurm/j%j.manual_run_kat_hist_k41.out
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=484Gb
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

out_dir="/home/sejoslin/git_repos/genome_assembly/output/kat_raw"
cd ${out_dir}

call="kat hist -H 75000000000 -o F_tnx_k41_kat_gcp -m 41 --verbose -t ${threads} ${infiles[0]} ${infiles[1]}"
echo ${call}
eval ${call}

sstat --format 'JobID,MaxRSS,AveCPU' -P ${SLURM_JOB_ID}.batch
