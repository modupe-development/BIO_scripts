#!/usr/bin/perl
use strict;
$|=1;
# - - - - - H E A D E R - - - - - - - - - - - - - - - -
# Submit batch BLAST queries.
# - - - - - U S E R   V A R I A B L E S - - - - - - - -
my $datetag = "12JUL";
# - - - - - G L O B A L  V A R I A B L E S  - - - - - -
my $perlshell = "#!/bin/sh
#\$ -cwd
#\$ -S /bin/sh
#\$ -j y
#\$ -pe threaded 4
#\$ -m bae
#\$ -M amodupe\@udel.edu
#\$ -N ";

my $directory = "/home/amodupe/analysis/s_bowtie/6bowtie/filessorted/";

# - - - - - M A I N - - - - - - - - - - - - - - - - - -
my $input = $ARGV[0];
#my $output = $ARGV[1];
my $position = 0;
my $count = 10000;
open(INPUT,$input) or die "Cant find $input\n\n";
my @content = <INPUT>;
my $total = sprintf "%.0f",($#content+1)/$count;
close (INPUT);
my $j;
for $j (0..$total){
    my $RUNname = "Trial-".$j;
    my $outfile = "Scut-".$datetag."-".$j.".sam";
    my $finaloutput = "SAMout-".$datetag."-".$j.".txt";
    my @distribution = splice(@content, $position , $count);
    open (OUTFILE, ">$outfile"); print OUTFILE @distribution; close (OUTFILE);
    open (OUT,">PERLshell.sh");
    print OUT $perlshell;
    print OUT "$RUNname\n\n";
    print OUT "perl ~/Scripts/15-sortingthesamfile.pl $directory$outfile $directory$finaloutput";
    close(OUT);
	
    print `qsub PERLshell.sh`;
}
print "Total of $j+1 files\n**********DONE************\n";
