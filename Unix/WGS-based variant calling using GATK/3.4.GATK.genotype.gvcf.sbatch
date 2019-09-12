#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename

#SBATCH --time=72:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=8  # 36 processor core(s) per node 
#SBATCH --mem=64G   # maximum memory per node
#SBATCH --job-name="gvcf"
#SBATCH --array=1-20
#SBATCH --output="logs/out.genotype.%A_%a.txt" # job standard output file (%j replaced by job id)
#SBATCH --error="logs/err.genotype.%A_%a.txt" # job standard error file (%j replaced by job id)
#SBATCH --dependency=afterok:2604570


# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE


i=$(($SLURM_ARRAY_TASK_ID - 1))

chr_intervals=(`cat sscrofa.chr1-18.X.list` Yplus)
ID=(`ls results/0.7.haplotypecaller.out/*chr${chr_intervals[$i]}.g.vcf.gz`)

fasta=~/haibol_work/haibo_genome/sus_scrofa/Sus_scrofa.Sscrofa11.1.dna.toplevel.fa
KNOWN_INDEL=~/haibol_work/haibo_genome/sus_scrofa/sus_scrofa.sorted.vcf

module load gatk/3.8-0-6lrc5l4
GATK=/opt/rit/spack-app/linux-rhel7-x86_64/gcc-4.8.5/gatk-3.8-0-6lrc5l4nx2ghvfshym5jcmys3xaibign/bin/GenomeAnalysisTK.jar

out=results/0.8.GenotypeGVCFs.out
mkdir -p $out

### Perform joint genotyping on gVCF files produced by HaplotypeCaller

variant=()
for j in ${ID[@]}
do
     variant+=("--variant $j")
done

java -Xmx8G -Djava.io.tmpdir=$TMPDIR -jar $GATK -T GenotypeGVCFs \
    -R $fasta \
    ${variant[@]}  \
    -nt 8 \
    -o $out/MARC.chr${chr_intervals[$i]}.gDNA.joint.vcf
