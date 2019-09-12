#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=48:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=3  # 36 processor core(s) per node 
#SBATCH --mem=36G   # maximum memory per node
#SBATCH --job-name="markdup"
#SBATCH --array=17
#SBATCH --output="logs/out.metrics.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.metrics.%A_%a.txt" # job standard error file (%j replaced by job id)
#SBATCH --dependency=afterok:2604205

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE


i=$(($SLURM_ARRAY_TASK_ID - 1))

libs=(`ls results/0.2.DNA-seq.cmb.12.markdup.out/* -d`)

bam=(`ls ${libs[$i]}/*.bam`)

bams=()
for k in $(eval echo "{0..$((${#bam[@]} - 1))}")

do
   bams+=("-I ${bam[$k]}")
done


dir=(`ls results/0.2.DNA-seq.cmb.12.markdup.out/* -d | perl -p -e 's{.+/(\d+_LIB.+)}{$1}'`)

gatk_dir=results/0.6.DNA-seq.baserecal.out/${dir[$i]}
mkdir -p ${gatk_dir}

module load jdk/8u172-b11-rnauqmr
module load gatk/3.8-0-6lrc5l4
GATK=/opt/rit/spack-app/linux-rhel7-x86_64/gcc-4.8.5/gatk-3.8-0-6lrc5l4nx2ghvfshym5jcmys3xaibign/bin/GenomeAnalysisTK.jar

fasta=~/haibol_work/haibo_genome/sus_scrofa/Sus_scrofa.Sscrofa11.1.dna.toplevel.fa
KNOWN_INDEL=~/haibol_work/haibo_genome/sus_scrofa/sus_scrofa.sorted.vcf


## Analyze patterns of covariation in the sequence dataset
#java -Xmx8G -XX:+UseParallelGC -XX:ParallelGCThreads=20 \
#    -Djava.io.tmpdir=$TMPDIR -jar $GATK  -T BaseRecalibrator \
#    -R  $fasta \
#    ${bams[@]}  \
#    -nct 40 \
#    -knownSites  ${KNOWN_INDEL} \
#    --bqsrBAQGapOpenPenalty 30 \
#    -o ${gatk_dir}/${dir[$i]}.recal_data.table 

## performs the second pass in a two-stage process called Base Quality Score Recalibration (BQSR). 
## replace PrintReads in GATK 2 and 3
java -Xmx16G -Djava.io.tmpdir=$TMPDIR  -jar $GATK  -T PrintReads \
    -R $fasta \
    ${bams[@]} \
    -nct 3 \
    --bam_compression 2 \
    --BQSR  ${gatk_dir}/${dir[$i]}.recal_data.table \
    -o  ${gatk_dir}/${dir[$i]}.recal.bam 

    

