#!/usr/bin/perl
use strict;
#checking file
my $input = $ARGV[0];
open (FILE, $input) or die print "File \'$input\' doesn't exist\n";
$input =~ m/^(.+).fastq$/;
my $output ="$1.filt.fastq";

print "The code of sequencing type\n\t\tSanger - S\n\t\tSolexa - X\n\t\tIllumina 1.3+ - I\n\t\tIllumina 1.5+ - J\n\t\tIllumina 1.8+ - L\n";
print "CODE\t:\t";
my $code = <STDIN>;
chomp $code;
my $result;
if ($code =~ m/[SsLl]/){
    $result = 33;
}elsif ($code =~ m/[XxIiJj]/){
    $result = 64;
}else {
    print "Doesn't exist"; exit;
}
my %QUALITY1 = '';
my @file1 = <FILE>;
chomp @file1;
close (FILE);
my ($i, $j, $l);
my %ASCII ='';
#loading the hash dictionary
&ASCII1;
my $wrote = 0;
open (OUT, ">$output");
print "--------FASTQ details of the ",($#file1+1)/4," sequences-------\n\n";
CHECK: for ($i = 0; $i < $#file1;$i+=4){
    $j = $i+1;$l = $j+2;
    my ($seq, $seqquality, $seqname) = ('', '','');   #<--- the nucleotide sequence, quality score, sequence name
    $seqname = $file1[$i];
    $seq = $file1[$j];
    $seqquality = $file1[$l];
    my @sequence = split('',$seq);
    my %COUNT = ();
    my $totallength=0;
    #1st check : if the read does not contain more than 50% N in whole length
    foreach my $nucleo (@sequence){
        $COUNT{$nucleo}++; $totallength++;
    }
    my $percentN = ($COUNT{'N'}/$totallength)*100;
    if ($percentN > 50){
        next CHECK;
    }
    
    #2nd check : if the read does not contain any N's in the first 25 bases
    my $testsequence = substr($seq,0,25);
    my @testseq = split('',$testsequence);
    foreach my $nucleo (@testseq){
        if ($nucleo eq 'N'){
            next CHECK;
        }
    }
    #3rd check : if quality values are all 2 or higher (2 means 35 in the ASCIII table for Solexa, for Illumina is 66) in the first 25 bases
    my $testquality = substr($seqquality,0,25);
    my @testqual = split('',$testquality);
    my $finalresult = $result +2;
    foreach my $qual (@testqual){
        if($ASCII{$qual} < ($result+2)){
            next CHECK;
        }
    }
    print OUT "$file1[$i]\n$file1[$i+1]\n$file1[$i+2]\n$file1[$i+3]\n";
    $wrote++;
}
print "\n\n     SUCCESS!!!\n-------Data has been printed out to file '$output'\nWrote $wrote\n";
close (OUT);
exit;
#==============================================================================
#SUBROUTINES
#===============================================================================
sub ASCII1{
    my $number = 33;
    my @aa = split(//,"!\"#\$%&\'()*+,-./0123456789:;<=>?\@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~");
    foreach my $a (@aa){$ASCII{$a}=$number;$number++;}
}

