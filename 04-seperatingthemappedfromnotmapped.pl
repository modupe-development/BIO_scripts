#!usr/bin/perl
use strict;

# - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
$a = "\t**SORTING THE BOWTIE MAPPED ALIGNMENTS\n\n";
$b = "Type in the name of the \"desired file\"\n\n";
# - - - - - U S E R    V A R I A B L E S  - - - - - - - - - -
my $inputfile = $ARGV[0];
open (FILE, "<$inputfile") or die "$a$b Cannot find file $inputfile\n";
my @dfile = <FILE>;
close(FILE);

#output
#$inputfile =~m/(s_\d)_(\w+).sam/;
my $output_mapped = $inputfile.".mapped.sam"; 	#"$1-mapped_$2.sam";
my $output_notmapped = $inputfile.".non-mapped.sam"; 	#"$1-non-mapped_$2.sam";
open (OUTPUTM, ">$output_mapped");
open (OUTPUTN, ">$output_notmapped");


# - - - - - G L O B A L  V A R I A B L E S  - - - - - - - - -
my $mapnumber = 0;
my $notmapnumber = 0;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - M A I N - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 1. getting the result
until ($dfile[0] !~ m/^@.*/){
    print OUTPUTM $dfile[0];
    print OUTPUTN $dfile[0];
    shift @dfile;
}
foreach my $line (@dfile){
    my @map = split('\t',$line);
    if ($map[2] =~ m/^\*.*/){ 
        print OUTPUTN $line;
        $notmapnumber++;
    }else {
        print OUTPUTM $line;
        $mapnumber++;
    }
}

print "\nFor $inputfile=>Total number of mapped reads is $mapnumber\n";
print "For $inputfile=>Total number of not mapped read is $notmapnumber\n\n";
print "Successfully saved in the outputfile $output_mapped & $output_notmapped\n";
close(OUTPUTM);
close(OUTPUTN);




