#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=12:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=1   # 36 processor core(s) per node 
#SBATCH --mem=128G   # maximum memory per node
#SBATCH --job-name="markdup"
#SBATCH --array=3-4
#SBATCH --output="logs/out.markdup.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.markdup.%A_%a.txt" # job standard error file (%j replaced by job id)

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE


export i=$(($SLURM_ARRAY_TASK_ID))

cd results
file=../docs/DNA-seq.markdup.lib.list.fmtted
PE=(`grep 'PE' $file | perl -n -e 'print if $. == $ENV{i}' `)
if [ "$i" == "3" ] || [ "$i" == "4" ]; then
  libraries=`grep 'PE' $file | perl -n -e 'print if $. == $ENV{i}' |cut -f1 | perl -p -e 's{.+/(LIB\d+).+.bam}{$1}'`
else
  libraries=`grep 'PE' $file | perl -n -e 'print if $. == $ENV{i}' |cut -f1 | perl -p -e 's{.+/(.+)/.+.bam}{$1}'`
fi
out=~/haibol_work/MARC_ASE/results/0.2.DNA-seq.cmb.12.markdup.out/${libraries}
mkdir -p $out


module load jdk/8u172-b11-rnauqmr
PICARD=/home/haibol/bin/picar_2.18.16/picard.jar

## NextSeq uses  unpatterned flow cells: OPTICAL_DUPLICATE_PIXEL_DISTANCE=100
java -jar -Xmx16G -Djava.io.tmpdir=$TMPDIR  $PICARD MarkDuplicates \
      ${PE[@]} \
      O=${out}/${libraries}.PE.markdup.bam \
      MAX_RECORDS_IN_RAM=null \
      MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
      ASSUME_SORT_ORDER=coordinate  \
      OPTICAL_DUPLICATE_PIXEL_DISTANCE=100 \
      CREATE_INDEX=true \
      M=${out}/${libraries}.PE.markdup_metrics.txt

