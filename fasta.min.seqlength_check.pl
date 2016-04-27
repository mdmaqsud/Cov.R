#!/usr/bin/perl
use strict;
use warnings;


unless (defined $ARGV[1]) {print "\n[Fasta file] [min length]\n"; exit;}

my $file = $ARGV[0];
my $min_length = $ARGV[1];
   
open FASTA, "$file";
open OUT, ">$file\.min\.$min_length\.fa";

{
local $/ = '>'; 
<FASTA>;                                             # throw away the first line 'cos will only contain ">"

while (<FASTA>) 
	{	
    	chomp $_;
    	my ($seq_id, @sequence) = split "\n";            # split the fasta input into Id and sequence
    	my $fasta_sequence = join '',@sequence;          # reassembles the sequence
		my $seq_length = length $fasta_sequence;
		if ($seq_length >= $min_length)
		{
		print OUT "\>$seq_id\n$fasta_sequence\n";
		}
	}
}
close FASTA;
close OUT;