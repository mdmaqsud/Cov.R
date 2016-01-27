#!/bin/bash
#$ -N star_sam2bam.sh
#$ -o star_sam2bam.sh..stdout
#$ -e star_sam2bam.$TASK_ID.stderr
#$ -cwd -l h_rt=168:00:00,mem_free=35G -q long.q -pe OpenMP 1
##$ -m BEa -M mdmaqsud@yahoo.com
##$ -t 200
source ~/.bashrc
source /mnt/software/etc/gis.bashrc

## Muhammad Maqsud Hossain : GIS, Singapore: 16/11/2015

echo "USAGE: proivde star.sam  output_prefix"



in=$1
id=$2

## make separate bamfile for individual sam files and use them as single reads during merging using the proper option
samtools view -bS -q 20 -F4  $in  -o  ${id}.star.bam
samtools sort ${id}.star.bam ${id}.star.sorted
samtools index  ${id}.star.sorted.bam

