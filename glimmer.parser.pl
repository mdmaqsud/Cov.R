#!/usr/bin/perl
use strict;
use warnings;

unless (exists $ARGV[0]) {print "FILE\n";exit;}

my $file = $ARGV[0];

open FILE, $file;
my $node = "";

while (<FILE>)
{
chomp $_;

if ($_ =~ /^\>(NODE.*)/){$node = $1;}

if ($_ =~ /^(orf.*?)\s+(\d+)\s+(\d+)\s+([+-])\d+\s+/)
	{
	my $orf = $1;
	my $start = $2;
	my $end = $3;
	my $strand = $4;
	print "$node\t$orf\t$start\t$end\t$strand\n";
	}

}
