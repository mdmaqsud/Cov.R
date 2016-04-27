#!/usr/bin/perl 
use warnings;
use strict;


unless (exists $ARGV[0]) {print "produce a normalised (per position) SNP and Indel score for an alignment\n[fasta file]\n";exit;}

my $infile = $ARGV[0];

open FASTA, $infile;

my @ids = ();
my @seqs = ();
my @nucs = ();
my @nuc_count = ();
my %sequences;
my ($seq_id, @sequence);
my $length = 0;
my $total_indels = 0;

{
local $/ = '>'; 
<FASTA>;                                             # throw away the first line 'cos will only contain ">"

while (<FASTA>) 
	{	
    	chomp $_;
    	($seq_id, @sequence) = split "\n";            # split the fasta input into Id and sequence
    	my $fasta_sequence = join '',@sequence;          # reassembles the sequence
	@nucs = ($fasta_sequence =~ /(.{1})/g); 
	$sequences{$seq_id} = [@nucs];
	push @ids, $seq_id;

	$length = scalar @nucs;
	}
}
close FASTA;

my $position = 0;
my $numberofseqs = scalar @ids;

my $perfect = 0;
my $variable = 0;

while ($position < $length)
{
my @residues = ();
my $print = "";

	foreach $seq_id (@ids)
		{
		if ($sequences{$seq_id}[$position] eq "-") {$total_indels++;}
		else {push @residues, "$sequences{$seq_id}[$position]";}
		}
my @uniq_array = uniq_array(@residues);
my $variance = 0.0;

if (scalar @uniq_array == 0) {}
else {$variance = sprintf ("%.1f", (($numberofseqs/(scalar @uniq_array)))/$numberofseqs);}
if ($variance == 1.0) {$perfect++;}
elsif ($variance =~ /\d+\.(\d+)/) {$variable++;}

$position++;
}

my $percentconserved = sprintf ("%.1f", (($perfect/$length)*100));
my $percent_indels = sprintf ("%.1f", ((($total_indels/$numberofseqs)/$length)*100));

print "Infile\tLength\tConserved\tVariable\tPercent_of_positions_Conserved\tPercent_of _positions_indels\n";
print "$infile\t$length\t$perfect\t$variable\t$percentconserved\t$percent_indels\n";



sub uniq_array{
##### make a unique list from the @genes array
my @in = @_;
my %seen = ();
my @uniq = ();
foreach (@in)
{chomp $_;
unless ($seen{$_}){
$seen{$_} = 1;
push (@uniq, $_);
}
}

return @uniq;
}
