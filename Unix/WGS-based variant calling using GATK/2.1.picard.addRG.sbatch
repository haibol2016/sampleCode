#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=12:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=4   # 36 processor core(s) per node 
#SBATCH --mem=96G   # maximum memory per node
#SBATCH --job-name="picard"
#SBATCH --array=13-82
#SBATCH --output="logs/out.addRG.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.addRG.%A_%a.txt" # job standard error file (%j replaced by job id)

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE


i=$(($SLURM_ARRAY_TASK_ID - 1))

in=results/bwa.out.05162019/WGS/*

bam=(`ls $in/*.bam`)
name=(`ls  $in/*.bam | perl -p -e 's{.+/(.+?).bam}{$1}'`)
dir=(`ls   $in/*.bam | perl -p -e 's{.+/WGS/(.+?)/.+}{$1}'`)
lib=(`ls   $in/*.bam | perl -p -e 's{.+/(.+?)_.+}{$1}' `)
animal_id=(`ls   $in/*.bam | perl -p -e 's{.+/WGS/(.+?)_LIB.+?/.+}{$1}'`)

out=results/0826.extra.WGS.addRG.out/${dir[$i]}
mkdir -p $out

module load jdk/8u172-b11-rnauqmr
PICARD=/home/haibol/bin/picar_2.18.16/picard.jar

java -jar -Xmx16G -Djava.io.tmpdir=$TMPDIR  $PICARD  AddOrReplaceReadGroups \
      I=${bam[$i]} \
      MAX_RECORDS_IN_RAM=null \
      O=${out}/${name[$i]}.addRG.bam  \
      SORT_ORDER=coordinate \
      RGID=${lib[$i]} \
      RGLB=${lib[$i]} \
      RGPL=ILLUMINA \
      RGPU=unit1 \
      RGSM=${animal_id[$i]} \
      CREATE_INDEX=true

