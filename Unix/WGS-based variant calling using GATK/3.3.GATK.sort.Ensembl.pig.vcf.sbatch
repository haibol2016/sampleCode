#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=1:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=1   # 36 processor core(s) per node 
#SBATCH --mem=16G   # maximum memory per node
#SBATCH --job-name="markdup"
#SBATCH --array=1
#SBATCH --output="logs/out.metrics.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.metrics.%A_%a.txt" # job standard error file (%j replaced by job id)

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

module load jdk/8u172-b11-rnauqmr
i=$(($SLURM_ARRAY_TASK_ID - 1))
PICARD=~/bin/picar_2.18.16/picard.jar
KNOWN_INDEL=~/haibol_work/haibo_genome/sus_scrofa/sus_scrofa.vcf

java -jar -Xmx16G -Djava.io.tmpdir=$TMPDIR  $PICARD SortVcf     I=${KNOWN_INDEL}  \
   O=~/haibol_work/haibo_genome/sus_scrofa/sus_scrofa.sorted.vcf  \
   SEQUENCE_DICTIONARY=~/haibol_work/haibo_genome/sus_scrofa/Sus_scrofa.Sscrofa11.1.dna.toplevel.dict
    

