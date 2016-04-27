#!/usr/local/bin/perl

#
#	Dr. Xiaodong Bai
#	It may be freely distributed under GNU General Public License.
#	This script will parse a NCBI blastx output file and output the top N hits of each blast search result.
#	For each hit, the following results are reported:
#	accesion number, length, description, E value, bit score, query frame, query start, query end, hit start, hit end, positives, and identical
# 	The results are tab-deliminated and ready for import into a spreadsheet program for browsing and further analysis.
#

use strict;
use warnings;
use Bio::SearchIO;

# Usage information
die "Usage: $0 <BLAST-report-file> <number-of-top-hits> <output-file>\n", if (@ARGV != 3);

my ($infile,$numHits,$outfile) = @ARGV;
print "Parsing the BLAST result ...";
my $in = Bio::SearchIO->new(-format => 'blast', -file => $infile);
open (OUT,">$outfile") or die "Cannot open $outfile: $!";

# print the header info for tab-deliminated columns
print OUT "query_name\tquery_length\taccession_number\tlength\tdescription\tE value\tbit score\tframe\tquery_start\t";
print OUT "query_end\thit_start\thit_end\tpositives\tidentical\n";

# extraction of information for each result recursively
while ( my $result = $in->next_result ) {
	# the name of the query sequence
   	print OUT $result->query_name . "\t";

        # the length of the query sequence
    	print OUT $result->query_length;

        # output "no hits found" if there is no hits
    	if ( $result->num_hits == 0 ) {
		print OUT "\tNo hits found\n";
    	} else {
		my $count = 0;

                # process each hit recursively
		while (my $hit = $result->next_hit) {
			print OUT "\t" if ($count > 0);
                        # get the accession numbers of the hits
			print OUT "\t" . $hit->accession . "\t";
                        # get the lengths of the hit sequences
                        print OUT $hit->length . "\t";
                        # get the description of the hit sequences
			print OUT $hit->description . "\t";
                        # get the E value of the hit
			print OUT $hit->significance . "\t";
                        #get the bit score of the hit
			print OUT $hit->bits . "\t";

                        my $hspcount = 0;

                        # process the top HSP for the top hit
			while (my $hsp = $hit->next_hsp) {
                        	print OUT "\t\t\t\t\t\t\t", if ($hspcount > 0);
                        	# get the frame of the query sequence
				print OUT $hsp->query->frame . "\t";
                                # get the start and the end of the query sequence in the alignment
				print OUT $hsp->start('query') . "\t" . $hsp->end('query'). "\t";
                                # get the start and the end of the hit sequence in the alignment
				print OUT $hsp->start('hit') . "\t" . $hsp->end('hit') . "\t";
                                # get the similarity value
				printf OUT "%.1f" , ($hsp->frac_conserved * 100);
				print OUT "%\t";
                                # get the identity value
				printf OUT "%.1f" , ($hsp->frac_identical * 100);
		       		print OUT "%\n";
                                $hspcount++;
                        }
			$count++;

                        # flow control for the number of hits needed
			last if ($count == $numHits);
		}
    	}
}
close OUT;
print " DONE!!!\n";

