#!/usr/bin/perl 
use warnings;
use strict;


use Getopt::Long;


# Richard Emes University of Nottingham 2010
my $usage = "
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
(C) R D Emes University of Nottingham 2010

pull multiple subsequences from fasta files

USAGE:
-f	fasta file 
-c	co-ordinates file [gene name], [start], [end], [strand (-/+)]
-o	output file
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
" ;


my ($fasta, $coord, $out);

GetOptions(
        'f|fasta:s'     => \$fasta,
        'c|coorrd:s'   => \$coord,
	'o|output:s'   => \$out,	
                 );


if( ! defined $fasta) {
print "$usage\nWARNING: Cannot proceed without directory of fasta files to process\n\n"; exit;
}
if( ! defined $coord) {
print "$usage\nWARNING: Cannot proceed coordinates file\n\n"; exit;
}
if( ! defined $out) {
print "$usage\nWARNING: Cannot proceed without output file\n\n"; exit;
}
####################################################

open OUT, ">$out";

# read in and sort coordinates file into chrosomes

my @list_of_fasta = (); # will hold a unique list of fasta files to process
my %fasta_lookup;

## read in fasta file 
my $fasta_sequence;
{
	open FASTA, "$fasta";
	{
	local $/ = '>'; 
	<FASTA>;                                             # throw away the first line 'cos will only contain ">"

	while (<FASTA>) 
		{	
		chomp $_;
		my ($seq_id, @sequence) = split "\n";            # split the fasta input into Id and sequence
		$fasta_sequence = join '',@sequence;          # reassembles the sequence
		@sequence = ();
		$fasta_lookup{$seq_id} = $fasta_sequence;
		}
	}
	close FASTA;
}

open COORD, $coord;

while (<COORD>)
{
chomp $_;
my @data = split '\t', $_;

my $name = $data[0]."_".$data[1];

my $start = $data[2];

my $start_print = $start;
$start--;
my $end = $data[3];
my $strand = $data[4];



if ($strand eq "+")
{
my $big = $end;
my $little = $start;

if ($start > $end){$big = $start; $little = $end; }	
$little--;
my $length = ($big-$little);

my $fasta_sequence = $fasta_lookup{$data[0]};
my $seq = substr($fasta_sequence, $little, $length); #$seq, start, length of substring)
print OUT "\>$name\_$start_print\_$end\n$seq\n";
}


if ($strand eq "-")
	{
	my $big = $start;
	my $little = $end;
	if ($end > $start){$big = $end; $little = $start};	
	
	my $length = ($big-$little);
	my $fasta_sequence = $fasta_lookup{$data[0]};
	my $print_end = $end;
	$little++;
	my $seq = substr($fasta_sequence, $little, $length); #$seq, start, length of substring)
	my $rev_comp = reverse $seq;
	$rev_comp =~ tr/NACGTacgtn/NTGCAtgcan/;
	$seq = $rev_comp;
	print OUT "\>$name\_$start_print\_$print_end\n$seq\n";
	}




}

