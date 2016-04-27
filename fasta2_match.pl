#!/usr/bin/perl
use strict;
use warnings;


unless (defined $ARGV[1]) {print "\n[Fasta file] [list of IDs to match]\n"; exit;}

my $file = $ARGV[0];
my $list2match = $ARGV[1];
   

my %fastalookup;
open FASTA, "$file";
open OUT, ">$file\.matched\.fa";
{
local $/ = '>'; 
<FASTA>;                                             # throw away the first line 'cos will only contain ">"

while (<FASTA>) 
	{	
    	chomp $_;
    	my ($seq_id, @sequence) = split "\n";            # split the fasta input into Id and sequence
    	my $fasta_sequence = join '',@sequence;          # reassembles the sequence
    	if ($seq_id =~ /([A-Za-z0-9\_\-]*)[\s\t]/){$seq_id = $1;}
		$fastalookup{$seq_id} = $fasta_sequence;
	}
}
close FASTA;

open LIST, "$list2match";
while (<LIST>)
{
chomp $_;
if (exists $fastalookup{$_})
	{
	print OUT "\>$_\n$fastalookup{$_}\n";
	}
}
close LIST;
close OUT;
