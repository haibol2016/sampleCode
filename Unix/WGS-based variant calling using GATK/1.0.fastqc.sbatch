#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=1:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=4   # 36 processor core(s) per node 
#SBATCH --mem=16G   # maximum memory per node
#SBATCH --job-name="fastqc"
#SBATCH --array=1-98
#SBATCH --output="logs/out.fastqc.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.fastqc.%A_%a.txt" # job standard error file (%j replaced by job id)

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

i=$(($SLURM_ARRAY_TASK_ID - 1))

module load fastqc/0.11.7-d5mgqc7

in=data/04292019.cmb.fastq/
fastq=(`ls $in/[DR]NA.fastq/*/*.gz`)
dir=(`ls  $in/[DR]NA.fastq/*/*.gz | perl -p -e 's{.+/(.+)/.+}{$1}'`)

out=results/fastqc.out/04292019.cmb.fastq/${dir[$i]}
mkdir -p $out

fastqc -o $out -t 4 --extract ${fastq[$i]}

