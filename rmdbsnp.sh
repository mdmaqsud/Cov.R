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


###############
#samtools index $rd1
###########convert vcf file using gokul's perl script

perl /mnt/projects/hossainmm/rna_editing/software/gokul_scripts/Convert_VCF.pl $in ${id}.gokul.convert

## remove variants from dbsnp databse###

cat ${id}.gokul.convert | awk '{OFS="\t";$2=$2-1"\t"$2;print $0}' | intersectBed -a stdin  -b $dbsnp  -v > ${id}.rmdbbsnp.138.bed

