#!/bin/bash

#copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=8   # 36 processor core(s) per node 
#SBATCH --mem=96G   # maximum memory per node
#SBATCH --job-name="bwa"
#SBATCH --array=1-8
#SBATCH --output="logs/out.bwa.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.bwa.%A_%a.txt" # job standard error file (%j replaced by job id)
#SBATCH --dependency=afterok:1230

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

i=$(($SLURM_ARRAY_TASK_ID - 1))

module load bwa/0.7.17-zhcbtza
module load samtools/1.9-k6deoga

in=data/05162019.WGS.repaired.fastq
R1=(`ls  $in/*/*R1.fq.gz`)
R2=(`ls  $in/*/*R2.fq.gz`)

name=(`ls  $in/*/*R1.fq.gz | perl -p -e   's{.+/(.+?).R1.fq.gz}{$1.PE}g' `)
dir=(`ls   $in/*/*R1.fq.gz | perl -p -e   's{.+/(.+)/.+?.R1.fq.gz}{$1}g' `)

out=results/bwa.out.05162019/WGS/${dir[$i]}
mkdir -p ${out}

fasta=~/haibol_work/haibo_genome/sus_scrofa/Sus_scrofa.Sscrofa11.1.dna.toplevel.fa

## paired-end 
time bwa mem -M -t 8 $fasta  ${R1[$i]} ${R2[$i]} | \
          samtools view -bu -h  -@ 8 - | samtools sort  -l 5 -m 8G -o $out/${name[$i]}.sort.bam  -O BAM -@ 8  -
