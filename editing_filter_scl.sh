#!/bin/bash
#$ -N editing.dbsnp.sh
#$ -o editing.dbsnp.sh.stdout
#$ -e editing.stderr
#$ -cwd -l h_rt=168:00:00,mem_free=35G -q long.q -pe OpenMP 2
##$ -m BEa -M mdmaqsud@yahoo.com
##$ -t 200
source ~/.bashrc
source /mnt/software/etc/gis.bashrc
dbsnp=/mnt/AnalysisPool/libraries/genomes/hg19/dbsnp/dbsnp_138.hg19.vcf

in=$1
id=$2


##Muhammad Maqsud Hossain 10/05/2016
#########separate alu and non-alu sites


perl /mnt/projects/hossainmm/rna_editing/GM12878/overlap.pl -C 1 -A 2 -B 3   $in   /mnt/projects/hossainmm/rna_editing/GM12878/bwa_mapping/alu.sorted.bed  > ${id}.overlap.txt

grep 'Z'  ${id}.overlap.txt | cut -f1,3-7  >  ${id}.overlap.alu.txt
########distribution in alu sites
sh distribution.fwd.45.sh ${id}.overlap.alu.txt ${id}.overlap.alu


awk '$6<1{print$0}' ${id}.overlap.alu.txt > ${id}.overlap.alu.rmhomzygous.txt


sh distribution.fwd.45.sh  ${id}.overlap.alu.rmhomzygous.txt ${id}.overlap.alu.rmhomzygous

##############non alu sites


grep 'A'  ${id}.overlap.txt | cut -f1,3-7 > ${id}.overlap.nonalu.txt

sh distribution.fwd.45.sh ${id}.overlap.nonalu.txt ${id}.overlap.nonalu

################Remove homoploymeric sites: need to provide 2 input:editing site file and output file name###############
perl /mnt/projects/hossainmm/rna_editing/software/gokul_scripts/RemoveHomoNucleotides.pl ${id}.overlap.nonalu.txt ${id}.overlap.nonalu.rmhom.txt

sh distribution.fwd.45.sh ${id}.overlap.nonalu.rmhom.txt ${id}.overlap.nonalu.rmhom


awk '$6<1{print$0}' ${id}.overlap.nonalu.rmhom.txt > ${id}.overlap.nonalu.rmhom.rmhomozygous.txt

sh distribution.fwd.45.sh ${id}.overlap.nonalu.rmhom.rmhomozygous.txt ${id}.overlap.nonalu.rmhom.rmhomozygous
