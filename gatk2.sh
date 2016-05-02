#!/bin/bash
#$ -N bwamem_gatk.sh
#$ -o bwamem_gatk.sh..stdout
#$ -e bwamem_gatk.sh.$TASK_ID.stderr
#$ -cwd -l h_rt=168:00:00,mem_free=40G -q long.q -pe OpenMP 2
##$ -m BEa -M mdmaqsud@yahoo.com
##$ -t 200
source ~/.bashrc
source /mnt/software/etc/gis.bashrc
dbsnp=/mnt/AnalysisPool/libraries/genomes/hg19/dbsnp/dbsnp_138.hg19.vcf
ref=/home/hossainmm/rna_editing/picard/hg19.fa
in=$1
id=$2


##ADD READGROUPS
java -Xmx4g -jar /mnt/software/bin/AddOrReplaceReadGroups.jar \
INPUT=$in \
OUTPUT=${id}.rg.bam \
SORT_ORDER=coordinate  \
VALIDATION_STRINGENCY=SILENT \
RGID=TMP RGLB=MGH30_E01 \
RGPL=ILLUMINA \
RGPU=TMP \
RGSM=TMP \
CREATE_INDEX=true

### RUNNING NCIGAR

wait
java -Xmx10g -jar /mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar  \
-T SplitNCigarReads \
-R $ref \
-I ${id}.rg.bam \
-o ncigar.${id}.bam \
-rf ReassignOneMappingQuality \
-RMQF 255 -RMQT 60 \
-U ALLOW_N_CIGAR_READS

wait

####calling target intervals######
java -Xmx10g -jar /mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar \
-T RealignerTargetCreator \
-o ${id}.intervals \
-I ncigar.${id}.bam \
-R $ref \
-known /mnt/AnalysisPool/libraries/genomes/hg19/dbsnp/dbsnp_138.hg19.vcf -nt 4

wait 


#########ralignment########################

java -Xmx10g -jar /mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar \
-I ncigar.${id}.bam \
-R $ref  \
-T IndelRealigner \
-targetIntervals ${id}.intervals \
-o ${id}.realigned.bam \
-known /mnt/AnalysisPool/libraries/genomes/hg19/dbsnp/dbsnp_138.hg19.vcf

wait

###############call covariants#############

java -Xmx10g -jar /mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar \
-l INFO -R $ref \
-I ${id}.realigned.bam \
-T BaseRecalibrator \
-knownSites /mnt/AnalysisPool/libraries/genomes/hg19/dbsnp/dbsnp_138.hg19.vcf  \
-cov ContextCovariate -cov CycleCovariate -cov ContextCovariate -o ${id}.grp

wait 

##Recalibrate
##=================
java -Xmx10g -jar /mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar \
-l INFO \
-R $ref \
-T PrintReads \
-I ${id}.realigned.bam \
-o ${id}.recalibrated.bam \
-BQSR ${id}.grp

wait 
####calling genotype
##=======================

# call variants using UnifiedGenotyper
# as suggested by Robert Piskol by mail
java -Xmx10g -jar /mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar -T UnifiedGenotyper \
-R $ref \
-I ${id}.recalibrated.bam \
-stand_call_conf 0 \
-stand_emit_conf 0 \
--dbsnp /mnt/AnalysisPool/libraries/genomes/hg19/dbsnp/dbsnp_138.hg19.vcf \
-out_mode EMIT_VARIANTS_ONLY \
-rf BadCigar \
-o ${id}.unified.genotyper.vcf \
-nt 4 \
-nct 4



