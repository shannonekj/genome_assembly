#!/bin/bash
#SBATCH --array=1-5
#SBATCH -J lqc
#SBATCH -e slurm/j%j.a%a.bash.longqc_stats.err
#SBATCH -o slurm/j%j.a%a.bash.longqc_stats.out
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=MaxMemPerNode
#SBATCH --time=02-12
#SBATCH -p bigmemm

# This script uses long read hifi data to produce the following "raw" data statistics:
#   * average_qv.png
#   * coverage.png
#   * gcfrac.png
#   * length.png
#   * masked_region.png


###############
###  SETUP  ###
###############

# conda things
echo "Initializing environment."
. ~/miniconda3/etc/profile.d/conda.sh
conda activate lqc
echo -e "    Done.\n"

fastqs=("/home/sejoslin/git_repos/genome_assembly/input/data/raw/F_hifi_a.fastq" "/home/sejoslin/git_repos/genome_assembly/input/data/raw/F_hifi_b.fastq" "/home/sejoslin/git_repos/genome_assembly/input/data/raw/F_hifi_c.fastq" "/home/sejoslin/git_repos/genome_assembly/input/data/raw/M_hifi_a.fastq" "/home/sejoslin/git_repos/genome_assembly/input/data/raw/M_hifi_b.fastq")
x=${SLURM_ARRAY_TASK_ID}
echo "x is ${x}"
fq=${fastqs[$(( $x - 1))]}
echo -e "Processing file ${fq}\n"

echo "Making variables"
file=$(echo $fq | rev | cut -f1 -d/ | rev)
prefix=$(basename $file .fastq)
out_dir="/home/sejoslin/git_repos/genome_assembly/output/longqc/${prefix}"
echo "   File : ${fq}"
echo "   Prefix : ${prefix}"
echo -e "Output Directory : ${out_dir}\n"

lqc_dir="/home/sejoslin/software/LongQC"


#############
###  RUN  ###
#############
[[ -d ${out_dir} ]] || mkdir -p ${out_dir}
cd ${out_dir}

# run longQC
echo "Running LongQC.py"
python ${lqc_dir}/longQC.py sampleqc -x pb-hifi -o ${prefix} ${fq}
echo -e "    Complete!"

sstat --format 'JobID,MaxRSS,AveCPU' -P ${SLURM_JOB_ID}.batch
