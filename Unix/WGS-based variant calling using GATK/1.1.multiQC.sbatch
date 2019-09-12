#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=1:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=1   # 36 processor core(s) per node 
#SBATCH --mem=16G   # maximum memory per node
#SBATCH --job-name="fastqc"
#SBATCH --array=1-16
#SBATCH --output="logs/out.fastqc.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.fastqc.%A_%a.txt" # job standard error file (%j replaced by job id)

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

i=$(($SLURM_ARRAY_TASK_ID - 1))

dir=(`ls -d results/fastqc.out/04292019.cmb.fastq/* | perl -p -e 's{.+/(.+)}{$1}'`)
out_dir=results/MultiQC.out/${dir[$i]}
mkdir -p ${out_dir}

## using multiqc installed in a virtual environment
source ~/bin/system.py3.6.5_env/bin/activate

multiqc --filename  04292019.${dir[$i]}.multiQC  \
        --outdir     ${out_dir} \
        results/fastqc.out/04292019.cmb.fastq/${dir[$i]}