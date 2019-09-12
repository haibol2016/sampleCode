#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=12:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=4   # 36 processor core(s) per node 
#SBATCH --mem=32G   # maximum memory per node
#SBATCH --job-name="picard"
#SBATCH --array=1
#SBATCH --output="logs/out.addRG.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.addRG.%A_%a.txt" # job standard error file (%j replaced by job id)

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE


i=$(($SLURM_ARRAY_TASK_ID - 1))


module load jdk/8u172-b11-rnauqmr

vcf=results/1.0.GATK.cmb.vcf.filtered.out/1.0.MARC.combined.14.pig.SNPs.pass.filtering.vcf
fasta=~/haibol_work/haibo_genome/sus_scrofa/Sus_scrofa.Sscrofa11.1.dna.toplevel.fa
KNOWN_INDEL=~/haibol_work/haibo_genome/sus_scrofa/sus_scrofa.sorted.vcf
out=results/1.0.GATK.cmb.vcf.filtered.out/1.0.GATK.varianteval.out

mkdir -p $out


module load gatk/3.8-0-6lrc5l4
GATK=/opt/rit/spack-app/linux-rhel7-x86_64/gcc-4.8.5/gatk-3.8-0-6lrc5l4nx2ghvfshym5jcmys3xaibign/bin/GenomeAnalysisTK.jar

java -Xmx8G -Djava.io.tmpdir=$TMPDIR -jar $GATK  \
   -T VariantEval \
   -nt 4 \
   -R $fasta \
   -o $out/1.o.14.pig.variant.evaluated.eval.grp \
   --eval $vcf  \
   --dbsnp ${KNOWN_INDEL} \

