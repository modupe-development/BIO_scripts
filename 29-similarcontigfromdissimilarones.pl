#!/usr/bin/perl
use strict;
# to extract similar contigs

#- - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
my $a = "\t**SELECTING THE SIMILAR AND NOT SIMILAR CONTIGS**\n\n";
my $b = "Type in the name of the \n\t\t1.\"common file\".\n\t\t2. The \"testfile\".\n\t\t3. The unique_outputfilename.\n\t\t4. The common_outputfilename\n\n";
# - - - - - U S E R V A R I A B L E S - - - - - - - - - -
my %comparison = '';
# the comparison file
my $inputcommon = $ARGV[0]; open (FILE, "<$inputcommon") or die "$a$b Cannot find file $inputcommon\n";
my @commonfile = <FILE>; close FILE;
#the test file
my $input = $ARGV[1]; open (INPUTFILE, "<$input") or die "Cannot find file $input\n";
my @inputfile = <INPUTFILE>; close INPUTFILE;

# the output files
my $output_only = $ARGV[2]; open (OUTPUTFILE, ">$output_only");
my $output_common = $ARGV[3]; open(OUTPUTFILE2, ">$output_common");

# - - - - - G L O B A L V A R I A B L E S - - - - - - - - -
# counting the reads
my $unique_count = 0;
my $common_count = 0;
# common variables
my $commonlist;
#test file variables
my $list;
my %sequencename;
# all variables
my @concat_list_commonlist;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# - - - - - - - - - - -
#1. getting the list for the common regions
my $i = 0;
foreach my $commonline (@commonfile){
    if ($commonline=~m/^>.*/){
        $i++;
        $sequencename{$commonline} = $i;
    }
}
# 2. getting the list for the test file
foreach my $inputlinenumber (0..$#inputfile){
    if ($inputfile[$inputlinenumber]=~m/^>.*/){
        if (exists $sequencename{$inputfile[$inputlinenumber]}){
            print OUTPUTFILE2 "$inputfile[$inputlinenumber]$inputfile[$inputlinenumber+1]";
            $common_count++;
        } else {
            print OUTPUTFILE "$inputfile[$inputlinenumber]$inputfile[$inputlinenumber+1]";
            $unique_count++;
        }
    }
}
print "Total number of unique reads in \"$ARGV[1]\" that is not in \"$ARGV[0]\" are \"$unique_count\".\n";
print "Total number of common reads in both \"$ARGV[0]\" and \"$ARGV[1]\" are \"$common_count\".\n";
print "Successfully saved in the outputfile $output_only & $output_common";
close OUTPUTFILE;
close OUTPUTFILE2;
print "\n\n*****************DONE*****************\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - S U B R O U T I N E S - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

