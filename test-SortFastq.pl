#! usr/bin/perl
use strict;
use a0subroutine1;
#truncate the FASTQ file into a string

my @files = <*.txt>;

my %QUALITY1 = '';
print "--------FASTQ details of the ",scalar @files," files-------\n\n";
for my $i (0..$#files){
    my ($seqname,$seq, $seqquality) = GETFASTQ($files[$i]);     #<--- getting the seqname, sequence & quality scores
    my $Quality = substr($seqquality,1,1);                      #<--- getting the quality score(ASCII) from the sequence.
    my $Qualityvalue = ASCII($Quality);                         #<--- converting ASCII to hex.
    #print "$seqname : $Quality =  $Qualityvalue\n\n";          #<--- testing the dictionary
    $QUALITY1{$seqname} = $Qualityvalue;
}
#sorting the values based on the second quality score
print "Sorting the FASTQ sequences based on the 2nd quality score---\n\n";
my @sorted = sort { $QUALITY1{$a} cmp $QUALITY1{$b} } keys %QUALITY1;   #<--- sorting the list of sequences based on their quality scores
foreach my $names (0..$#sorted){                                #<--- print out each sequence name
    print "$sorted[$names]\n";
}
