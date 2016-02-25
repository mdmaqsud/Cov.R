#!/bin/bash
#$ -N bwamem_gatk.sh
#$ -o bwamem_gatk.sh..stdout
#$ -e bwamem_gatk.sh.$TASK_ID.stderr
#$ -cwd -l h_rt=168:00:00,mem_free=35G -q long.q -pe OpenMP 2
##$ -m BEa -M mdmaqsud@yahoo.com
##$ -t 200
source ~/.bashrc
source /mnt/software/etc/gis.bashrc
ref=/mnt/AnalysisPool/libraries/genomes/hg19/bowtie2_path/base/hg19.fa

# Get the bam file from the command line
DATA=$1
id=$2

# Forward strand.
#
# 1. alignments of the second in pair if they map to the forward strand
# 2. alignments of the first in pair if they map to the reverse  strand
#
samtools view -b -f 128 -F 16 $DATA > ${id}.fwd1.bam
samtools sort ${id}.fwd1.bam ${id}.fwd1.sorted
samtools index ${id}.fwd1.sorted.bam

samtools view -b -f 80 $DATA > ${id}.fwd2.bam
samtools sort ${id}.fwd2.bam ${id}.fwd2.sorted
samtools index ${id}.fwd2.sorted.bam

#
# Combine alignments that originate on the forward strand.
#
samtools merge -f ${id}.fwd.bam ${id}.fwd1.sorted.bam ${id}.fwd2.sorted.bam
samtools sort ${id}.fwd.bam ${id}.fwd.sorted
samtools index ${id}.fwd.sorted.bam

# Reverse strand
#
# 1. alignments of the second in pair if they map to the reverse strand
# 2. alignments of the first in pair if they map to the forward strand
#
samtools view -b -f 144 $DATA > ${id}.rev1.bam
samtools sort ${id}.rev1.bam ${id}.rev1.sorted
samtools index ${id}.rev1.sorted.bam

samtools view -b -f 64 -F 16 $DATA > ${id}.rev2.bam
samtools sort ${id}.rev2.bam ${id}.rev2.sorted
samtools index ${id}.rev2.sorted.bam
#
# Combine alignments that originate on the reverse strand.
#
samtools merge -f ${id}.rev.bam ${id}.rev1.bam ${id}.rev2.bam
samtools sort ${id}.rev.bam ${id}.rev.sorted
samtools index ${id}.rev.sorted.bam
