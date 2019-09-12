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


i=$(($SLURM_ARRAY_TASK_ID - 1))

gatk_dir=results/1.0.GATK.cmb.vcf.filtered.out/
mkdir -p ${gatk_dir}
vcf=(`ls results/0.9.GATK.cmb.vcf.out/*.vcf`)

name=(`ls results/0.9.GATK.cmb.vcf.out/*.vcf | perl -p -e 's{.+/(.+?).vcf}{$1}'`)

fasta=~/haibol_work/haibo_genome/sus_scrofa/Sus_scrofa.Sscrofa11.1.dna.toplevel.fa
KNOWN_INDEL=~/haibol_work/haibo_genome/sus_scrofa/sus_scrofa.sorted.vcf

module load gatk/3.8-0-6lrc5l4
GATK=/opt/rit/spack-app/linux-rhel7-x86_64/gcc-4.8.5/gatk-3.8-0-6lrc5l4nx2ghvfshym5jcmys3xaibign/bin/GenomeAnalysisTK.jar

# 1. Extract the SNP from the call set
java -Xmx16G -jar $GATK -T SelectVariants \
    -R $fasta \
    -V ${vcf[$i]}  \
    -selectType SNP \
    -o ${gatk_dir}/${name[$i]}.SNPs.vcf

### 2. Determine parameters for filtering SNPs
java -Xmx16G -jar $GATK \
    -T VariantFiltration \
    -R $fasta \
    -V  ${gatk_dir}/${name[$i]}.SNPs.vcf \
    --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 3.0" \
    --filterName "default_snp_filter" \
    -o ${gatk_dir}/${name[$i]}.filtered.SNPs.vcf

### 3. Extract the Indels from the call set

java -Xmx16G -jar $GATK \
    -T SelectVariants \
    -R $fasta \
    -V ${vcf[$i]} \
    -selectType INDEL \
    -o ${gatk_dir}/${name[$i]}.INDELs.vcf

### 4. Determine parameters for filtering Indels.
java -Xmx16G -jar $GATK \
    -T VariantFiltration \
    -R $fasta \
    -V ${gatk_dir}/${name[$i]}.INDELs.vcf  \
    --filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0" \
    --filterName "default_indel_filter" \
    -o  ${gatk_dir}/${name[$i]}.filtered.INDELs.vcf


