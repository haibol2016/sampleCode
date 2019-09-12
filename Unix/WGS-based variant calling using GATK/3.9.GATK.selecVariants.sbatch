#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=12:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=1   # 36 processor core(s) per node 
#SBATCH --mem=8G   # maximum memory per node
#SBATCH --job-name="picard"
#SBATCH --array=2-8
#SBATCH --output="logs/out.addRG.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.addRG.%A_%a.txt" # job standard error file (%j replaced by job id)

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE


i=$(($SLURM_ARRAY_TASK_ID - 1))


module load jdk/8u172-b11-rnauqmr
module load vcftools 

vcf=results/1.0.GATK.cmb.vcf.filtered.out/1.0.MARC.combined.14.pig.SNPs.pass.filtering.vcf
fasta=~/haibol_work/haibo_genome/sus_scrofa/Sus_scrofa.Sscrofa11.1.dna.toplevel.fa
KNOWN_INDEL=~/haibol_work/haibo_genome/sus_scrofa/sus_scrofa.sorted.vcf
out=results/1.0.GATK.cmb.vcf.filtered.out/1.0.GATK.selectVariant.out

mkdir -p $out
fathers=(201123907 201012311)
fathers+=(${fathers[@]})

mothers=(201017403 201148704 201117903 201144502)

fathers_full=()
mothers_full=()

## parental IDs of trios
for j in {0..3}
do
  for k in {0..1}
  do
     fathers_full+=(${fathers[$j]})
     mothers_full+=(${mothers[$j]})
  done
done 

## offspring IDs
offspring=(101740302 101740304 114870402 114870406 111790303 111790308 114450204  114450205)

module load gatk/3.8-0-6lrc5l4
GATK=/opt/rit/spack-app/linux-rhel7-x86_64/gcc-4.8.5/gatk-3.8-0-6lrc5l4nx2ghvfshym5jcmys3xaibign/bin/GenomeAnalysisTK.jar

#java -Xmx8G -Djava.io.tmpdir=$TMPDIR -jar $GATK  \
#   -T SelectVariants \
#   -R $fasta \
#   -V $vcf \
#   -o $out/2.0.trios.${i}.vcf \
#   -sn ${fathers_full[$i]} \
#   -sn ${mothers_full[$i]} \
#   -sn ${offspring[$i]} 


#generate Mendelian error statistics
#NOTE, sample.vcf contains 3 samples!
seqmule stats -vcf $out/2.0.trios.${i}.vcf  --plink --mendel-stat \
              --paternal  ${fathers_full[$i]} \
              --maternal ${mothers_full[$i]} \
              --prefix $out/2.0.trios.${i}.stats.txt
