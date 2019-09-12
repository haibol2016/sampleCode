#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=6:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=1   # 36 processor core(s) per node 
#SBATCH --mem=32G   # maximum memory per node
#SBATCH --job-name="markdup"
#SBATCH --array=1-8
#SBATCH --output="logs/out.metrics.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.metrics.%A_%a.txt" # job standard error file (%j replaced by job id)

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE


i=$(($SLURM_ARRAY_TASK_ID - 1))

bam=(`ls results/markdup.out/LIB*/*.bam`)
name=(`ls results/markdup.out/LIB*/*.bam | perl -p -e 's{.+/(.+).markdup.bam}{$1}'`)
dir=(`ls results/markdup.out/LIB*/*.bam | perl -p -e 's{.+?/.+?/(.+?)/.+?.markdup.bam}{$1}'`)

out=results/markdup.out/${dir[$i]}/align.metrics
mkdir -p $out

module load jdk/8u172-b11-rnauqmr
module load r/3.5.0-py2-x335hrh

PICARD=/home/haibol/bin/picar_2.18.16/picard.jar
fasta=~/haibol_work/haibo_genome/sus_scrofa/Sus_scrofa.Sscrofa11.1.dna.toplevel.fa

java -Xmx8G -jar  -Djava.io.tmpdir=$TMPDIR  $PICARD CollectAlignmentSummaryMetrics \
            R=$fasta I=${bam[$i]}  O=${out}/${name[$i]}.alignment_metrics.txt
java -Xmx8G -jar  -Djava.io.tmpdir=$TMPDIR   $PICARD CollectInsertSizeMetrics INPUT=${bam[$i]}  \
            OUTPUT=${out}/${name[$i]}.insert_metrics.txt  \
            HISTOGRAM_FILE=${out}/${name[$i]}.insert_size_histogram.pdf
