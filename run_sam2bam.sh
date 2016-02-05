rd1=$1
rd2=$2
id=$3
bwa_index=/home/hossainmm/rna_editing/xenopus/xenopus_tropicalis/ucsc/GCF_000004195.2_Xtropicalis_v7_genomic.fna

bwa aln -t 5 $bwa_index $rd1 > ${id}.r1.sai &
bwa aln -t 5 $bwa_index $rd2 > ${id}.r2.sai

wait

bwa samse -n 4 $bwa_index ${id}.r1.sai $rd1  > ${id}.r1.sam &

bwa samse -n 4 $bwa_index ${id}.r2.sai $rd2 > ${id}.r2.sam
wait

## make separate bamfile for individual sam files and use them as single reads during merging using the proper option
samtools view -bS -q 20 -F4  ${id}.r1.sam -o  ${id}.r1.bam &
samtools view -bS -q 20 -F4  ${id}.r2.sam -o  ${id}.r2.bam
wait
samtools sort ${id}.r1.bam  ${id}.r1.sorted &
samtools sort  ${id}.r2.bam  ${id}.r2.sorted
wait
samtools index  ${id}.r1.sorted.bam &
samtools index ${id}.r2.sorted.bam
wait


samtools merge ${id}.merged.bam ${id}.r1.sorted.bam  ${id}.r2.sorted.bam

samtools sort ${id}.merged.bam ${id}.merged.sorted
samtools index ${id}.merged.sorted.bam

##Remove duplicate reads using picard tool
java -Xmx10g -jar /mnt/software/bin/MarkDuplicates.jar INPUT=${id}.merged.sorted.bam REMOVE_DUPLICATES=true VALIDATION_STRINGENCY=LENIENT METRICS_FILE=$file.metrices.txt OUTPUT=${id}.rd.bam ASSUME_SORTED=$

