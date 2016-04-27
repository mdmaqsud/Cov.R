#!/usr/bin/perl 
use warnings;
use strict;

my %CODON_TABLE = (
   TCA => 'S',TCG => 'S',TCC => 'S',TCT => 'S',
   TTT => 'F',TTC => 'F',TTA => 'L',TTG => 'L',
   TAT => 'Y',TAC => 'Y',TAA => 'X',TAG => 'X',
   TGT => 'C',TGC => 'C',TGA => 'X',TGG => 'W',
   CTA => 'L',CTG => 'L',CTC => 'L',CTT => 'L',
   CCA => 'P',CCG => 'P',CCC => 'P',CCT => 'P',
   CAT => 'H',CAC => 'H',CAA => 'Q',CAG => 'Q',
   CGA => 'R',CGG => 'R',CGC => 'R',CGT => 'R',
   ATT => 'I',ATC => 'I',ATA => 'I',ATG => 'M',
   ACA => 'T',ACG => 'T',ACC => 'T',ACT => 'T',
   AAT => 'N',AAC => 'N',AAA => 'K',AAG => 'K',
   AGT => 'S',AGC => 'S',AGA => 'R',AGG => 'R',
   GTA => 'V',GTG => 'V',GTC => 'V',GTT => 'V',
   GCA => 'A',GCG => 'A',GCC => 'A',GCT => 'A',
   GAT => 'D',GAC => 'D',GAA => 'E',GAG => 'E',
   GGA => 'G',GGG => 'G',GGC => 'G',GGT => 'G',
   "---" => '-'
   );




my $fasta_in = shift or die "\nUSAGE: ***.pl [FASTA_FILE]\n";



my %fasta;
my $seq_id;
my $fasta_sequence;
my @sequence;
my @ids;
my $codon;
open CDNA, $fasta_in;
{
local $/ = '>'; 
<CDNA>;                                  # throw away the first line 'cos will only contain ">"

open CDNAPEP, ">$fasta_in.pep";


while (<CDNA>) {
    chomp $_;

    ($seq_id, @sequence) = split "\n";            # split the fasta input into Id and sequence
    $fasta_sequence = join '',@sequence;          # reassembles the sequence
my @codons = ();
my @cdna2pep = ();
my $cdna2pep = 0;
    @codons = split (/(.{3})/, $fasta_sequence);

foreach $codon (@codons)
	{
	chomp $codon;
	my $length = length $codon;
	if ($length == 3){
	
	
	if (exists $CODON_TABLE{uc $codon}){push @cdna2pep, $CODON_TABLE{uc $codon};}
	else {push @cdna2pep, "u";}
	}
	}
    
if (exists $cdna2pep[0]){$cdna2pep = join '', @cdna2pep;}

$cdna2pep =~ s/X$//;                      # strips the stop codon if exists from the end 
                                               #of the sequence or prints error if stop in the middle of the sequence.
	if ($cdna2pep =~ /X/g) 
		{
	open ERRORS, ">>$fasta_in.ERRORS";
	print ERRORS "\n----------ERROR---------\nOne or more sequences contain a stop codon this may confuse your analysis. The sequences are listed below:\n\n";
	print ERRORS "$seq_id", "\t", "$cdna2pep", "\n";
	print CDNAPEP "\>$seq_id\n$cdna2pep\n";       # capture the cDNA translation (FASTA)
	       }

	    else {
		print CDNAPEP "\>$seq_id\n$cdna2pep\n";       # capture the cDNA translation (FASTA) cdna2pep_translation.tmp
		    }

}
}
close CDNAPEP;
close ERRORS;