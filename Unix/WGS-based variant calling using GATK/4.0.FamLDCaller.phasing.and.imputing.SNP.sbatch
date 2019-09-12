#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=72:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=4   # 36 processor core(s) per node 
#SBATCH --mem=96G   # maximum memory per node
#SBATCH --job-name="picard"
#SBATCH --array=1
#SBATCH --output="logs/out.addRG.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.addRG.%A_%a.txt" # job standard error file (%j replaced by job id)

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE


i=$(($SLURM_ARRAY_TASK_ID - 1))

vcf=results/1.0.GATK.cmb.vcf.filtered.out/1.0.MARC.combined.14.pig.SNPs.pass.filtering.vcf
ped=results/1.0.GATK.cmb.vcf.filtered.out/marc_ABE.ped

FamLDCaller --vcf $vcf --pedfile  $ped  --rounds 50  \
            --prefix  results/1.0.GATK.cmb.vcf.filtered.out/1.0.famldcaller.MARC.ABE.
