#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=12:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=4   # 36 processor core(s) per node 
#SBATCH --mem=8G   # maximum memory per node
#SBATCH --job-name="trim"
#SBATCH --array=1-5
#SBATCH --output="logs/out.rcorrect.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.rcorrect.%A_%a.txt" # job standard error file (%j replaced by job id)

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

module load trimmomatic/0.36-lkktrba

i=$(($SLURM_ARRAY_TASK_ID - 1))

module load java/1.8.0_171

R1=(`ls cmb.raw.fastq/*R1*gz`)
R2=(`ls cmb.raw.fastq/*R2*gz`)

name=(`ls cmb.raw.fastq/*R1*gz | perl -p -e   's{.+/(.+?)_.+.gz}{$1}g' `)
adapters=~/bin/Trimmomatic-0.36/all.adapter.fa
out=trimmed.RNA.fastq_2
mkdir -p ${out}

java -jar -Xmx8G ~/bin/Trimmomatic-0.36/trimmomatic-0.36.jar  PE -threads 4  \
          ${R1[$i]}  ${R2[$i]} \
          -baseout  ${out}/${name[$i]}.fq.gz  \
          ILLUMINACLIP:${adapters}:2:30:7:1:true  \
          LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15  MINLEN:25

