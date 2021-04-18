#!/bin/bash
#SBATCH --array=1-5
#SBATCH -J lqc
#SBATCH -e slurm/j%j.bash.longqc_stats.err
#SBATCH -o slurm/j%j.bash.longqc_stats.out
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
fastqs=()
x=${SLURM_ARRAY_TASK_ID}
echo "x is ${x}"
k=${fastqs[$(( $x - 1))]}
