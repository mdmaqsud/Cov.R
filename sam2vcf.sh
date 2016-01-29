	
samtools pileup -f myReference.fasta myReads.bam >myPileup.pileup
java -jar VarScan.jar pileup2snp myPileup.pileup

#To save on disk space and I/O, you can also use a UNIX "pipe" command to forward the pileup output directly into VarScan:

	
#samtools pileup -f myRef.fasta myBam.bam | java -jar VarScan.jar pileup2s
