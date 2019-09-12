#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=72:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=36  # 36 processor core(s) per node 
#SBATCH --mem=72G   # maximum memory per node
#SBATCH --job-name="gvcf"
#SBATCH --array=1-14
#SBATCH --output="logs/out.DNA.haplotypecaller.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.DNA.haplotypecaller.%A_%a.txt" # job standard error file (%j replaced by job id)
#SBATCH --dependency=afterok:2604561

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE


i=$(($SLURM_ARRAY_TASK_ID - 1))

pigs=(`ls results/0.6.DNA-seq.baserecal.out/* -d | perl -p -e 's{.+/(\d+)_LIB.+}{$1}' | sort -u`)

bams=(`ls results/0.6.DNA-seq.baserecal.out/${pigs[$i]}_LIB*/*.recal.bam`)

gatk_dir=results/0.7.haplotypecaller.out/
mkdir -p ${gatk_dir}

fasta=~/haibol_work/haibo_genome/sus_scrofa/Sus_scrofa.Sscrofa11.1.dna.toplevel.fa
KNOWN_INDEL=~/haibol_work/haibo_genome/sus_scrofa/sus_scrofa.sorted.vcf

module load gatk/3.8-0-6lrc5l4
GATK=/opt/rit/spack-app/linux-rhel7-x86_64/gcc-4.8.5/gatk-3.8-0-6lrc5l4nx2ghvfshym5jcmys3xaibign/bin/GenomeAnalysisTK.jar

sample_interval=()


for j in $(eval echo "{0..$((${#bams[@]} - 1))}")
do
     sample_interval+=("-I ${bams[$j]}")
done
sample_interval+=("-L  intervals.list")
out_name=${pigs[$i]}.chrYplus 


## Xmx < 30G, otherwise coredump
java -jar -Xmx16G -Djava.io.tmpdir=$TMPDIR ${GATK}  -T HaplotypeCaller \
    -R $fasta \
    ${sample_interval[@]} \
    --dbsnp $KNOWN_INDEL \
   --emitRefConfidence GVCF \
    -stand_call_conf 30 \
    -nct 36  \
    -o  ${gatk_dir}/${out_name}.g.vcf.gz
