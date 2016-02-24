#!/bin/bash
#$ -N editing.dbsnp.sh
#$ -o editing.dbsnp.sh.stdout
#$ -e editing.stderr
#$ -cwd -l h_rt=168:00:00,mem_free=35G -q long.q -pe OpenMP 2
##$ -m BEa -M mdmaqsud@yahoo.com
##$ -t 200
source ~/.bashrc
source /mnt/software/etc/gis.bashrc

in=$1
id=$2

#Remove homoploymeric sites: need to provide 2 input:editing site file and output file name
perl /mnt/projects/hossainmm/rna_editing/software/gokul_scripts/RemoveHomoNucleotides.pl $in ${id}.rmrepeats.rmhmpol.txt
