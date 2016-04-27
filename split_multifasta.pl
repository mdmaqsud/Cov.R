#Muhammad Maqsud Hossain 
use strict;
use warnings;

use Tie::File::AnyData::Bio::Fasta;

tie my @in,'Tie::File::AnyData::Bio::Fasta', shift @ARGV, or die $!;

my $n = 0;
for my $seq (@in){
  tie my @out, 'Tie::File::AnyData::Bio::Fasta', "$n.fa" or die $!;
  $n++;
  @out = ($seq);
  untie @out;
}

untie @in;
