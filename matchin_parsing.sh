#!/bin/bash
#$ -N bwamem_gatk.sh
#$ -o bwamem_gatk.sh..stdout
#$ -e bwamem_gatk.sh.$TASK_ID.stderr
#$ -cwd -l h_rt=168:00:00,mem_free=50G -q long.q -pe OpenMP 2
##$ -m BEa -M mdmaqsud@yahoo.com  
##$ -t 200
source ~/.bashrc
source /mnt/software/etc/gis.bashrc


in=$1
id=$2

awk '{print$1":"$2}' $in > ${id}.matched.txt  # grab column 1 and 2 separated by colon

python matching.py ${id}.matched.txt parsed_masterlist > ${id}.parsed.matched.list.txt # make binary file based on the list 
ls *parsed.matched.list.txt > filelist
