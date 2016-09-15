#!/usr/bin/perl
use strict;
# to extract the not listed SNPs - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
$a = "\t**SELECTING THE SIMILAR AND NOT SIMILAR ALIGNMENTS**\n\n"; $b = "Type in the name of the \"common file\" FIRST then the \"testfile\"\n\n";
# - - - - - U S E R V A R I A B L E S - - - - - - - - - -
my %comparison = '';
# the comparison file
my $inputcommon = $ARGV[0]; open (FILE, "<$inputcommon") or die "$a$b Cannot find file $inputcommon\n"; my @commonfile = <FILE>; close FILE;
#the files BOWTIE and CLC
my $input = $ARGV[1]; open (INPUTFILE, "<$input") or die "Cannot find file $input\n"; my @inputfile = <INPUTFILE>; close INPUTFILE;

# the output file
$input =~ m/analysis\/(\S*)\/s_(\d)_without.sam/; my $output_only = "onlyinthis_5-$1-$2.sam"; open (OUTPUTFILE, ">$output_only");

# - - - - - G L O B A L V A R I A B L E S - - - - - - - - - common variables
my $commonlist;
#test file variables
my $list;
# all variables
my @concat_list_commonlist;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# - - - - - - - - - - - 1. getting the list for the common regions
foreach my $commonline (@commonfile){
    if ($commonline=~m/^HW*/){
        my @commonline = split('\t',$commonline);
        $commonlist .= "|$commonline[0]";
    }
}
# 2. getting the list for the test file
print OUTPUTFILE $inputfile[2]; foreach my $inputline (@inputfile){
    if ($inputline=~m/^HWI.*/){
        my @inputline = split('\t',$inputline);
        $list .= "|$inputline[0]";
    }
}
my $concat_list_commonlist = "$list$commonlist"; @concat_list_commonlist = split('\|',$concat_list_commonlist);
#3. getting the reads
my @similar = (); my %seen; foreach my $elem (@concat_list_commonlist){
    next if $seen{$elem}++;
    push (@similar, $elem);
}
#4. getting the only in test file $output_only reads
my @sort = sort {$a <=> $b} keys %seen; my $com = 0; foreach my $read(@sort){
    if ($read=~m/^HWI.*/){
        if ($seen{$read} == 1) {
            foreach my $line (@inputfile){
                if ($line=~m/^HWI.*/){
                    my @lines = split('\t',$line);
                    if ($read eq $lines[0]){
			$com++;
                        print OUTPUTFILE $line;
                    }
                }
            }
        }
    }
}
print "Total number of unique reads in \"$ARGV[1]\" is \"$com\".\n"; print "Successfully saved in the outputfile $output_only"; close OUTPUTFILE; print 
"\n\n*****************DONE*****************\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - S U B R O U T I N E S - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
