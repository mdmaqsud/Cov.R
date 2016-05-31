#!/bin/bash
#$ -N bwamem_gatk.sh
#$ -o bwamem_gatk.sh..stdout
#$ -e bwamem_gatk.sh.$TASK_ID.stderr
#$ -cwd -l h_rt=168:00:00,mem_free=60G -q long.q -pe OpenMP 2
##$ -m BEa -M mdmaqsud@yahoo.com
##$ -t 200
source ~/.bashrc
source /mnt/software/etc/gis.bashrc
in=$1
id=$2

/home/hossainmm/rna_editing/software/STAR-STAR_2.4.0i/bin/Linux_x86_64/STAR \
--genomeDir /mnt/projects/hossainmm/rna_editing/picard  \
--sjdbGTFfile /mnt/AnalysisPool/libraries/genomes/hg19/gtf/hg19_annotation.gtf \
--outFilterMismatchNmax 3 --runThreadN 8 --outSAMstrandField intronMotif \
--outFileNamePrefix ${id}.star   \
--outSAMtype BAM SortedByCoordinate  \
--readFilesIn $in
