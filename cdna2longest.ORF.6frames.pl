#!/usr/bin/perl
use strict;
use warnings;

############################################################################
# R D EMES UCL Dec 2006

############################################################################
############################################################################
############################################################################

unless (exists $ARGV[0]) {print "\n[DNA Fasta file to search]\n
finds longest ORFs split by \"TAG\", \"TGA\" or \"TAA\" in cDNA sequence\n\n"; exit;}

my $file = $ARGV[0];
my $regex1 = "TAG";
my $regex2 = "TGA";
my $regex3 = "TAA";

open FASTA, "$file";
open OUTFASTA, ">$file\.longest\.ORF";

my @ids;
my %forward;
my %reverse;

{
local $/ = '>';
<FASTA>;
	while (<FASTA>)
	{
	chomp;
	my($id, @seq) = split "\n";
   	my $seq = join '', @seq;
	chomp $seq;
 	my $reverse = reverse $seq;
  	$reverse =~ tr/ACGTacgt/TGCAtgca/;
	push @ids, $id;
	$forward{$id} = $seq;
	$reverse{$id} = $reverse;
	}
}
close FASTA;

my $id = "";

foreach $id (@ids){
my $seq = "";
my $dir = "";
my $check = 0;
my $current_longest = 0;
my @orfs = ();
my $frame = 0;


while ($check < 2)
{

my $forward = $forward{$id};
my $reverse = $reverse{$id};
if ($check == 0) {$seq = $forward;$dir = "f";}
elsif ($check == 1) {$seq = $reverse;$dir = "r";}

my $trueend = length($seq);
while ($frame < 3)
{
my $workingseq = $seq;
my $length = length $seq;
$workingseq = substr($seq, $frame, $length);
#print "$frame\t$length\t$workingseq\n";

my @start_stops = ();
my @codons = ();
my @stops = ();
my $position = 0;
my $nt_position = 0;
my $nt_start = 0; # start of codon encoding a stop
my $nt_end = 0;
my %codons;
my $foo = 0;
my $stop_present = 0;
my $ORF = "";

#my $trash = ""; # contains all trailing sequence not split in to codons
@codons = split (/(.{3})/,$workingseq);
foreach (@codons)
{
chomp $_;
$codons{$_} = $foo;

if ($_ =~ (/^\s*$/)){}
elsif ($_ =~ (/($regex1|$regex2|$regex3)/i))
{
$position++;
$nt_position = ((($position*3)-2)+$frame);
$stop_present = 1;
push @stops, $nt_position;
}	
else {$position++;$nt_position = ((($position*3)-2)+$frame);}
$foo++;
}

push @stops, $trueend+1;


my $start = 1;
foreach my $nt_stoppos(@stops)
{
chomp $nt_stoppos;
my $end = ($nt_stoppos-1);
push @start_stops,"$start $end";
$start = ($nt_stoppos+3);
}


	foreach (@start_stops)
	{
	chomp;
	my ($a,$b) = split ' ',$_;
	my $print_start = ($a);
	if ($a == 1) {$print_start = ($a+$frame);$a = ($a+$frame)}
# 	print "$id\t$frame\t$print_start\t$b\n";
	$a = ($a-1);
	my $stringlength = $b-$a;
	my $seqprint = substr($seq, $a, $stringlength); #$seq, start, length of substring)
	my $orf_length = (length $seqprint);

	
	unless ($orf_length < 3){
		
			if ($orf_length >= $current_longest)
			{
			my $printframe = $frame+1;
			$ORF = "$orf_length\t\>$id\_$dir$printframe\_$print_start\_$b\n$seqprint\n";
			$current_longest = $orf_length;
			push @orfs, $ORF;
			}
		}

	}
$frame++;
}
$check++;
$frame = 0;
}


my ($size,$stuff);
foreach (@orfs)
{
chomp;
($size,$stuff) = split '\t';
if ($size >= $current_longest)
{print OUTFASTA "$stuff\n";}
}
}
close OUTFASTA;