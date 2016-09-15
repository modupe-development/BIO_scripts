#!/usr/bin/perl
use strict;
$|=1;
# - - - - - H E A D E R - - - - - - - - - - - - - - - -
# Joining all the files together
# - - - - - U S E R   V A R I A B L E S - - - - - - - -
my $directory = "/home/amodupe/analysis/s_bowtie/6bowtie/filessorted/trials/";
my $output = $ARGV[0];
open(OUTPUT, ">$directory$output");close(OUTPUT);
# - - - - - M A I N - - - - - - - - - - - - - - - - - -
print "\n\n\nStarting . . . . \n";
opendir(DIR,$directory) or die "\n\n NADA $directory!\n\n\n";
my @Folders = readdir(DIR);
close(DIR);
my $end = $ARGV[1];
foreach my $number (0..$end){
    foreach my $folder (@Folders){
        if ($folder =~ m/^SAMout.*JUL-$number.txt/) { #my $finaloutput = "SAMout-".$datetag."-".$j.".txt";{
print $folder;
            $folder = $directory . $folder;
            open(FFN,$folder) or die "\n\nNADA  $folder\n\n\n";
            my @files = <FFN>;
            close(FFN);
            open (OUTPUT, ">>$directory$output"); print OUTPUT @files;close(OUTPUT);
        }
    }
}
print "\n**********DONE************\n";
 
