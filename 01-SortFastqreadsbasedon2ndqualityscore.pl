#!/usr/bin/perl
use strict;
#checking file
# 
#
my $input = $ARGV[0];
my %QUALITY1 = '';
unless(open (FILE, $input)){print "File \'$input\' doesn't exist\n";exit;}

my @file1 = <FILE>;
chomp @file1;
close (FILE);
my ($i, $j, $l);
#print "Input the name of the output file : ";
my $output = $input . ".output.txt";

open (OUT, ">$output");
print OUT "SEQUENCE NAME\tQUALITYSCORE\n";

print "--------FASTQ details of the ",($#file1+1)/4," sequences-------\n\n";
for ($i = 0; $i < $#file1;$i+=4){
    $j = $i+1;
    $l = $j+2;
    my $seq = '';#$file1[$i];					#<--- the nucleotide sequence
    my $seqquality = '';			#<--- the quality scores
    my $seqname = '';
    $seqname = $file1[$i];
    $seq = $file1[$j];
    $seqquality = $file1[$l];
    #print "Q = $seqquality\nN = $seqname\nS = $seq\n\n";
    my $Quality = substr($seqquality,1,1);                      #<--- getting the quality score(ASCII) from the sequence.
    my $Qualityvalue = ASCII1($Quality);                         #<--- converting ASCII to hex.
    #print "$seqname : $Quality =  $Qualityvalue\n\n";          #<--- testing the dictionary
    $QUALITY1{$seqname} = $Qualityvalue;
}
print "Sorting the FASTQ sequences based on the 2nd quality score---";
my @sorted = sort { $QUALITY1{$b} <=> $QUALITY1{$a} } keys %QUALITY1;   #<--- sorting the list of sequences based on their quality scores
foreach my $names (0..$#sorted){                                #<--- print out each sequence name
    #print "$sorted[$names] : $QUALITY1{$sorted[$names]}\n";
    print OUT "$sorted[$names]\t$QUALITY1{$sorted[$names]}\n";
    
}
print "\n\n     SUCCESS!!!\n-------Data has been printed out to file '$output'\n";
close (OUT);
exit;


#==============================================================================
#SUBROUTINES
#===============================================================================

sub ASCII1 {
    my ($Quality) = @_;
    #======creating the dictionary
    my %ASCII ='';
    #======opening the file
    my $filename = 'asciidata.ascii';
    unless (open (ASCIIFILE, $filename)){
        print "The file is not present ASCII: $filename\n";
        exit;
    }
    my @ascii = <ASCIIFILE>;
    close (ASCIIFILE);
    foreach my $line (@ascii){
    #creating the dictionary
        $line =~ m/(\S+)\s(\S+)/;
        $ASCII{$2} = $1;
    }
    #======returning a dictionary with the key value
    return $ASCII{$Quality};
}

