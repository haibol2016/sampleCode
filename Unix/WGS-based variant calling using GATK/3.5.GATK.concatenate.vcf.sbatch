#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=12:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=1  # 36 processor core(s) per node 
#SBATCH --mem=64G   # maximum memory per node
#SBATCH --job-name="gvcf"
#SBATCH --array=1
#SBATCH --output="logs/out.cmb.vcf.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.cmb.vcf.%A_%a.txt" # job standard error file (%j replaced by job id)

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE


#i=$(($SLURM_ARRAY_TASK_ID - 1))


gatk_dir=results/0.9.GATK.cmb.vcf.out
mkdir -p ${gatk_dir}

fasta=~/haibol_work/haibo_genome/sus_scrofa/Sus_scrofa.Sscrofa11.1.dna.toplevel.fa
KNOWN_INDEL=~/haibol_work/haibo_genome/sus_scrofa/sus_scrofa.sorted.vcf

module load gatk/3.8-0-6lrc5l4
GATK=/opt/rit/spack-app/linux-rhel7-x86_64/gcc-4.8.5/gatk-3.8-0-6lrc5l4nx2ghvfshym5jcmys3xaibign/bin/GenomeAnalysisTK.jar


#### concatenate all chromosome-wise vcf files togehter

vcfs=(`ls results/0.8.GenotypeGVCFs.out/*.vcf`)

variants=()

for i in ${vcfs[@]}

do
  variants+=("-V $i")
 
done


#### invoke it is a little different from other GATK tools (see example below), 
#### and it does NOT accept any of the classic "CommandLineGATK" arguments.

java -cp  ${GATK}  org.broadinstitute.gatk.tools.CatVariants \
    -R $fasta \
     ${variants[@]} \
    -out ${gatk_dir}/MARC.combined.12.pig.vcf \
    -assumeSorted


