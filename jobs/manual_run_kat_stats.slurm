#!/bin/bash
#SBATCH --array=1-5
#SBATCH -J kat10xF
#SBATCH -e slurm/j%j.a%a.manual_run_kat_stats.err
#SBATCH -o slurm/j%j.a%a.manual_run_kat_stats.out
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=MaxMemPerNode
#SBATCH --time=02-12
#SBATCH -p bigmemm

# Make arrays for manually running the following on F 10X data:
#   * kat hist k31 & k41
#   * kat comp k41
#   * kat gcp k31 & k41

# conda
echo "Loading environment."
# initialize conda
. ~/miniconda3/etc/profile.d/conda.sh
conda activate kat

set -e
set -x

infiles=("/home/sejoslin/git_repos/genome_assembly/input/data/raw/F_tnx_R1.fastq.gz" "/home/sejoslin/git_repos/genome_assembly/input/data/raw/F_tnx_R2.fastq.gz")
x=${SLURM_ARRAY_TASK_ID}
echo "x is ${x}"
threads=${SLURM_NTASKS}

out_dir="/home/sejoslin/git_repos/genome_assembly/output/kat_raw"
cd ${out_dir}

kat_cmd=("kat hist -o F_tnx_k31_kat_hist -m 31 -t ${threads} ${infiles[0]} ${infiles[1]}" "kat hist -o F_tnx_k41_kat_hist -m 41 -t ${threads} ${infiles[0]} ${infiles[1]}" "kat gcp -o F_tnx_k31_kat_gcp -m 31 -t ${threads} ${infiles[0]} ${infiles[1]}" "kat gcp -o F_tnx_k41_kat_gcp -m 41 -t ${threads} ${infiles[0]} ${infiles[1]}" "kat comp -n -o F_tnx_k41_kat_comp -m 41 -t ${threads} ${infiles[0]} ${infiles[1]}")
call=${kat_cmd[$(( $x - 1 ))]}

echo ${call}
eval ${call}
