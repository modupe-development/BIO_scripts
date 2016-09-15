#!/usr/bin/perl
use strict;
$|=1;
# - - - - - H E A D E R - - - - - - - - - - - - - - - -
# Joining all the files together
# - - - - - U S E R   V A R I A B L E S - - - - - - - -
my $directory = "/home/amodupe/Jen/DEHALO.1/genomes/";
my $output = $ARGV[0];
open(OUTPUT, ">$output");close(OUTPUT);
# - - - - - M A I N - - - - - - - - - - - - - - - - - -
print "\n\n\nStarting . . . . \n";
opendir(DIR,$directory) or die "\n\n NADA $directory!\n\n\n";
my @Folders = readdir(DIR);
close(DIR);
foreach my $folder (@Folders){
    if ($folder =~ m/.*\.fa$/) {
        $folder = $directory . $folder;
        open(FFN,$folder) or die "\n\nNADA  $folder doesn't exist\n\n\n";
        my @files = <FFN>;
        close(FFN);
        open (OUTPUT, ">>$output"); print OUTPUT @files;close(OUTPUT);
    }
}

print "\n**********DONE************\n";
 
