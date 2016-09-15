#!/usr/bin/perl
use strict;
# to extract the not listed SNPs in the commonfile
# sentence to work with
#### whatever that is not in $commonfile that $inputfile  has is save in $inputfile.xls
#
#####################################
#
# - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
$a = "\t**SELECTING THE NOT COMMON SNPS IN THE FILES**\n\n";
$b = "Type in the name of the \"VCF file\" FIRST then the \" CLCtxt file\"\n\n";

# - - - - - U S E R    V A R I A B L E S  - - - - - - - - - -
my %comparison = '';
# the comparison file
my $inputcommon = $ARGV[0];
open (FILE, "<$inputcommon") or die "$a$b Cannot find file $inputcommon\n";
my @commonfile = <FILE>;
close FILE;


#the SNP, beta or old
my $input = $ARGV[1];
open (INPUTFILE, "<$input") or die "Cannot find file $input\n";
my @inputfile = <INPUTFILE>;
close INPUTFILE;

# the output file
my $output = $input.".dupe";
open (OUTPUTFILE, ">$output");

# - - - - - G L O B A L  V A R I A B L E S  - - - - - - - - -
#common variables
my ($commonlist, @commonlist);

#file variables
my ($list, @list);
my @concat_list_commonlist;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - M A I N - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 1. getting the list for the common regions
#removing the first line
#shift @commonfile;
foreach my $commonline (@commonfile){
    my @commonline = split('\t',$commonline);
    $commonlist .= "|$commonline[1] ";
}
# 2. getting the SNP from file:
#printing the headers of the file to the output file
#print OUTPUTFILE $inputfile[0];
#removing the first line (the header line)
#shift @inputfile;
foreach my $inputline (@inputfile){
    my @inputline = split('\t',$inputline);
    $list .= "|$inputline[0] ";
}
#print $list; die;
my $concat_list_commonlist = "$list$commonlist";
@concat_list_commonlist = split('\|',$concat_list_commonlist);

#3. getting the unique SNPs
my @unique = ();
my %seen;
foreach my $elem (@concat_list_commonlist){
    next if $seen{$elem}++;
    push @unique,$elem;
}
print "\n";
my $listing=0;
#4. getting the SNPs that does exist in the $commonfile
my @sort = sort {$a <=> $b} keys %seen;
foreach my $number(@sort){
    if ($seen{$number} == 1) {  
        foreach my $line (@inputfile){
            my @line = split('\t',$line);
            if ($number == $line[0]){
                print OUTPUTFILE $line;
		$listing++;
            }
        }
    }
}
print "Successfully saved in the outputfile $output\n\ttotal unique SNPs is $listing";
close OUTPUTFILE;

print "\n\n*****************DONE*****************\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -



