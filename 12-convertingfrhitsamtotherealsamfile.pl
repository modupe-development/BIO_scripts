#!/usr/bin/perl
use strict;
# to change d frhit sam to the real sam file
#- - - - - - - - - - - -  - - - - H E A D E R - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$a = "\n\t**CHANGING THE FRHIT-SAM OUTPUTFILE TO THE USEFUL SAM OUTPUTFILE**\n\n";
$b = "Type in the name of the \"frhit sam file\" FIRST then the \"FASTQ file\"and the \"OUTPUT filename\"\n\n";
# - - - - - U S E R V A R I A B L E S - - - - - - - - - -
#open frhit file
open (FRHITFILE,"<$ARGV[0]") or die "$a$b Cannot find file $ARGV[0]\n";

# the output file
my $output = "$ARGV[2]"; open (OUTPUT, ">$output");
# - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - -- - - - - - - - -
# - - - - - - - - G L O B A L V A R I A B L E S - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - -- - - - - - - - -
# the fastq table
my %hashtable = ();

# - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - -- - - - - - - - -
#- - - - - - - - - - - - - - - -M A I N - - - - - - - - - - - - - - - - - - - - -
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#the hashtable
&Fastq($ARGV[1]);

while (<FRHITFILE>){
    my @sequal;
    my $frhit = $_;
    chomp $frhit;
    my @frhitline = split ("\t", $frhit);
    for(my $i=0; $i<9;$i++){
        print OUTPUT "$frhitline[$i]\t";
    }
    if ($frhitline[1] == 16){
        @sequal = split("\t", $hashtable{$frhitline[0]});
        $sequal[0] =~ tr/ATGC/TACG/;
        my $sequal0 = reverse($sequal[0]);
        my $sequal1 = reverse($sequal[1]);
        print OUTPUT "$sequal0\t$sequal1\t";
    }
    elsif($frhitline[1] == 0){
    @sequal = split("\t", $hashtable{$frhitline[0]});
    print OUTPUT "$sequal[0]\t$sequal[1]\t";
    }
print OUTPUT "$frhitline[11]\n";
}
print "Successfully saved in the outputfile $output\n"; close OUTPUT;
print "\n\n*****************DONE*****************\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  - - - - - - - - - - - - - -  S U B R O U T I N E S - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# to create the hash table
sub Fastq {
    my $sequence = 0;
    my $quality = 0;
    my $array ='';
    my $seq = '';
    my $qual = '';
    my $sequencename ='';
    open (FASTQ, "$ARGV[1]") or die "$a$b Cannot find file $ARGV[1]\n";
    while (<FASTQ>) {
        my $line = $_;
        chomp $line;
        if ($line =~ m/^@(.*)$/) { ## putting the sequence ID in $1
            $sequencename = $1;
            $sequence = 1;
        }
        elsif ($sequence == 1) {
            $seq = $line;
            $sequence = 0;
        }
        elsif ($line =~ m/^\+/) {
            $quality = 1;
        }
        elsif ($quality == 1) {
            $qual = $line;
            $quality = 0;
        }
        $array = "$seq\t$qual";
        $hashtable{$sequencename} = $array;
    }
    close(FASTQ);
    print "\nfastq done\n";
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

