#PBS -N SNPiR
#PBS -l nodes=1:ppn=8
#PBS -l mem=31gb
#PBS -l walltime=240:00:00
#PBS -m ea
#PBS -M mdmaqsud@yahoo.com

#Move tmp dir to scratch 
export TMPDIR=/scratch/meissto/$PBS_JOBID  #replace meissto with ur username
 
#Load specified module versions
#module load samtools
module load samtools/dnanexus-1.0
module load bwa
module load picard
module load gatk
module load bedtools
module load ucsc_tools # for blat
module load snpir
module load vcftools
 
export PERL5LIB="/gpfs/group/sanford/src/RNA" # point to one dir upstream of SNPiR config.pm

ncpu=$(grep -c "processor" /proc/cpuinfo) 
nthreads=$((ncpu/2))

hg19_reference="/gpfs/group/databases/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa"
RepeatMasker="/gpfs/group/databases/SNPiR/annotations/RepeatMasker.bed" 
gene_annotation="/gpfs/group/databases/SNPiR/annotations/anno_combined_sorted" 
rnaedit="/gpfs/group/databases/SNPiR/rnaedit/Human_AG_all_hg19.bed"
dbsnp="/gpfs/group/databases/GATK/hg19/dbsnp_137.hg19.vcf" 
mills="/gpfs/group/databases/GATK/hg19/Mills_and_1000G_gold_standard.indels.hg19.vcf"
g1000="/gpfs/group/databases/GATK/hg19/1000G_phase1.indels.hg19.vcf" 
bwa_index="/gpfs/group/databases/SNPiR/BWAIndex/hg19_genome_junctions.fa" 

extractvcf='/gpfs/group/su/meissto/scripts/extractvcf.R' # point to the location of the script
out_dir="/gpfs/group/su/meissto/results/SNPiR_test" # where should the results go to
encoding=phred64 #or phred33

#workaround ..
cp /opt/applications/snpir/bin/convertCoordinates.* $out_dir # seems to run only from the working dir

# input read1 & read2
in1="/gpfs/group/sanford/patient/SSKT/SSKT_1/RNA/RNA_seq/data/SSKT_1_1.fastq"
in2="/gpfs/group/sanford/patient/SSKT/SSKT_1/RNA/RNA_seq/data/SSKT_1_2.fastq"

# read group information for read1 & read2, is required for GATK
RGR1="@RG\tID:12345\tLB:TrueSeq\tPL:ILLUMINA\tSM:SSKT_1"
RGR2="@RG\tID:12345\tLB:TrueSeq\tPL:ILLUMINA\tSM:SSKT_1"


################################################################################
# MAPPING
################################################################################
# align with bwa as single reads
bwa aln -t $nthreads $bwa_index $in1 > $out_dir/out1.sai &
bwa aln -t $nthreads $bwa_index $in2 > $out_dir/out2.sai &

wait

bwa samse -n4 -r $RGR1 $bwa_index $out_dir/out1.sai $in1 > $out_dir/out1.sam &
bwa samse -n4 -r $RGR2 $bwa_index $out_dir/out2.sai $in2 > $out_dir/out2.sam &

wait

# merge alignments
cat $out_dir/out1.sam <(grep -v '^@' $out_dir/out2.sam) > $out_dir/merged.sam

# convert the position of reads that map across splicing junctions onto the genome
cd $out_dir
java -Xmx4g -cp . convertCoordinates < $out_dir/merged.sam > $out_dir/merged.conv.sam
cd ~

# rewrite the .sam header to drop the pseudochromosomes
samtools view -HS $out_dir/merged.conv.sam > $out_dir/header.sam
sed -n '1,25 p' $out_dir/header.sam > $out_dir/t1.sam
tail -n -1 $out_dir/header.sam > $out_dir/t2.sam
cat $out_dir/t1.sam $out_dir/t2.sam > $out_dir/new_header.sam

java -jar `which ReplaceSamHeader.jar` \
	INPUT=$out_dir/merged.conv.sam \
	HEADER=$out_dir/new_header.sam \
	OUTPUT=$out_dir/merged.conv.nh.sam 

# sort file, filter out unmappes reads and reads with mapping quality < 20 and convert to .bam
samtools view -bS -q 20 -F 4 $out_dir/merged.conv.nh.sam | samtools rocksort -@ $ncpu -m 1500M - $out_dir/merged.conv.nh.sort
# if rocksort wont work, use this: samtools view -bS -q 20 -F 4 $out_dir/merged.conv.nh.sam | samtools sort - $out_dir/merged.conv.nh.sort

# remove duplicate reads ###THIS PART FINISHES SUCCESSFULLY
java -Xmx4g -jar `which MarkDuplicates.jar` \
	INPUT=$out_dir/merged.conv.nh.sort.bam \
	REMOVE_DUPLICATES=true \
	VALIDATION_STRINGENCY=LENIENT \
	AS=true \
	METRICS_FILE=$out_dir/SM1.dups \
	OUTPUT=$out_dir/merged.conv.nh.sort.rd.bam \
	TMP_DIR=$TMPDIR

# index ###THIS PART WORKS
samtools index $out_dir/merged.conv.nh.sort.rd.bam

# indel realignment & base quality score recalibration ###THIS PART FINISHES SUCCESSFULLY
if [ $encoding == "phred64" ]; then
	java -Xmx16g -jar `which GenomeAnalysisTK.jar` \
		-T RealignerTargetCreator \
		-R $hg19_reference \
		-I $out_dir/merged.conv.nh.sort.rd.bam \
		-o $out_dir/output.intervals \
		-known $mills \
		-known $g1000 \
		-nt 8 \
		--fix_misencoded_quality_scores \
		--filter_reads_with_N_cigar
	
	java -Xmx16g -Djava.io.tmpdir=$TMPDIR -jar `which GenomeAnalysisTK.jar` \
		-I $out_dir/merged.conv.nh.sort.rd.bam \
		-R $hg19_reference \
		-T IndelRealigner \
		-targetIntervals $out_dir/output.intervals \
		-o $out_dir/merged.conv.sort.rd.realigned.bam \
		-known $mills \
		-known $g1000 \
		--consensusDeterminationModel KNOWNS_ONLY \
		-LOD 0.4 \
		--fix_misencoded_quality_scores \
		--filter_reads_with_N_cigar
else
	java -Xmx16g -jar `which GenomeAnalysisTK.jar` \
		-T RealignerTargetCreator \
		-R $hg19_reference \
		-I $out_dir/merged.conv.nh.sort.rd.bam \
		-o $out_dir/output.intervals \
		-known $mills \
		-known $g1000 \
		-nt 8 \
		--filter_reads_with_N_cigar
	
	java -Xmx16g -Djava.io.tmpdir=$TMPDIR -jar `which GenomeAnalysisTK.jar` \
		-I $out_dir/merged.conv.nh.sort.rd.bam \
		-R $hg19_reference \
		-T IndelRealigner \
		-targetIntervals $out_dir/output.intervals \
		-o $out_dir/merged.conv.sort.rd.realigned.bam \
		-known $mills \
		-known $g1000 \
		--consensusDeterminationModel KNOWNS_ONLY \
		-LOD 0.4 \
		--filter_reads_with_N_cigar
fi

###THIS PART FINISHES SUCCESSFULLY	
# Base Quality Score Recalibration
	#1 Analyze patterns of covariation in the sequence dataset
java -Xmx16g -jar `which GenomeAnalysisTK.jar` \
    -T BaseRecalibrator \
    -R $hg19_reference \
    -I $out_dir/merged.conv.sort.rd.realigned.bam \
    -knownSites $dbsnp \
    -knownSites $mills \
    -knownSites $g1000 \
    -o $out_dir/recal_data.table \
    -nct $ncpu
    
	#2 Do a second pass to analyze covariation remaining after recalibration
###THIS PART FINISHES SUCCESSFULLY
java -Xmx16g -jar `which GenomeAnalysisTK.jar` \
    -T BaseRecalibrator \
    -R $hg19_reference \
    -I $out_dir/merged.conv.sort.rd.realigned.bam \
    -knownSites $dbsnp \
    -knownSites $mills \
    -knownSites $g1000 \
    -BQSR $out_dir/recal_data.table \
    -o $out_dir/post_recal_data.table \
    -nct $ncpu

	#3 Generate before / after plots This part throws error
java -jar `which GenomeAnalysisTK.jar` \
    -T AnalyzeCovariates \
    -R $hg19_reference \
    -before $out_dir/recal_data.table \
    -after $out_dir/post_recal_data.table \
    -plots $out_dir/recalibration_plots.pdf
    
	#4 Apply the recalibration to your sequence data
java -jar `which GenomeAnalysisTK.jar` \
    -T PrintReads \
    -R $hg19_reference \
    -I $out_dir/merged.conv.sort.rd.realigned.bam \
    -BQSR $out_dir/recal_data.table \
    -o $out_dir/merged.conv.sort.rd.realigned.recal.bam
    
################################################################################
# Call/filter variants
################################################################################     
# call variants using UnifiedGenotyper
# as suggested by Robert Piskol by mail
java -Xmx16g -jar `which GenomeAnalysisTK.jar` -T UnifiedGenotyper \
	-R $hg19_reference \
	-I $out_dir/merged.conv.sort.rd.realigned.recal.bam \
	-stand_call_conf 0 \
	-stand_emit_conf 0 \
	--dbsnp $dbsnp \
	-out_mode EMIT_VARIANTS_ONLY \
	-rf BadCigar \
	-o $out_dir/raw_variants.vcf \
	-nt 4 \
	-nct 4

# do the filtering
# convert vcf format into custom SNPiR format and filter variants with quality <20
convertVCF.sh $out_dir/raw_variants.vcf $out_dir/raw_variants.txt 20

# filter mismatches at read ends
# note: add the -illumina option if your reads are in Illumina 1.3+ quality format
filter_mismatch_first6bp.pl \
	-infile $out_dir/raw_variants.txt \
	-outfile $out_dir/raw_variants.rmhex.txt \
	-bamfile $out_dir/merged.conv.sort.rd.realigned.bam

# filter variants in repetitive regions
awk '{OFS="\t";$2=$2-1"\t"$2;print $0}' $out_dir/raw_variants.rmhex.txt | \
	intersectBed -a stdin -b $RepeatMasker -v | \
	cut -f1,3-7 > $out_dir/raw_variants.rmhex.rmsk.txt

# filter intronic sites that are within 4bp of splicing junctions
# make sure your gene annotation file is in UCSC text format and sorted by chromosome and 
# transcript start position
filter_intron_near_splicejuncts.pl \
	-infile $out_dir/raw_variants.rmhex.rmsk.txt \
	-outfile $out_dir/raw_variants.rmhex.rmsk.rmintron.txt \
	-genefile $gene_annotation

# filter variants in homopolymers
filter_homopolymer_nucleotides.pl \
	-infile $out_dir/raw_variants.rmhex.rmsk.rmintron.txt \
	-outfile $out_dir/raw_variants.rmhex.rmsk.rmintron.rmhom.txt \
	-refgenome $hg19_reference

# filter variants that were caused by mismapped reads
# this may take a while depending on the number of variants to screen and the size of the reference genome
# note: add the -illumina option if your reads are in Illumina 1.3+ quality format
BLAT_candidates.pl \
	-infile $out_dir/raw_variants.rmhex.rmsk.rmintron.rmhom.txt \
	-outfile $out_dir/raw_variants.rmhex.rmsk.rmintron.rmhom.rmblat.txt \
	-bamfile $out_dir/merged.conv.sort.rd.realigned.bam \
	-refgenome $hg19_reference

# remove known RNA editing sites
awk '{OFS="\t";$2=$2-1"\t"$2;print $0}' $out_dir/raw_variants.rmhex.rmsk.rmintron.rmhom.rmblat.txt | \
	intersectBed -a stdin -b $rnaedit -v  > \
	$out_dir/raw_variants.rmhex.rmsk.rmintron.rmhom.rmblat.rmedit.bed
	
# extract variants from the raw vcf
skipn=$(cat $out_dir/raw_variants.vcf | grep '#' | wc -l)
cat $out_dir/raw_variants.vcf | grep '#' > $out_dir/header.vcf 
Rscript $extractvcf $out_dir $skipn
cat $out_dir/header.vcf $out_dir/red_variants.vcf > $out_dir/final_variants.vcf

################################################################################
# clean up stuff..
################################################################################
shopt -s extglob
cd $out_dir
#rm !(final_variants.vcf)

exit 0
