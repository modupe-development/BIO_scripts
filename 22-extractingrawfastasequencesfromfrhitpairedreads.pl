#!/usr/bin/perl 
use strict;

#--- this script will in-put a fasta file and split read 1 and read 2 into 2 different out-put
#--- files from illumina data
my $help = "Input \"FASTA1 file\" , \"FASTA2 file\", \"FRHIT paired file\", and \"Genome name\" \n";
#................................
#MAIN VARIABLES
#................................
my $readsone = "FRHIT_$ARGV[3]_illumina_reads_1.fna";
my $readstwo = "FRHIT_$ARGV[3]_illumina_reads_2.fna";
my $quality = 0;

open(OUT1, ">$readsone");  #should contain name and sequence
open(OUT2, ">$readstwo");
#................................
#USER VARIABLES
#................................

my $seq_id;
my $sequence;
my %sequence_hash;
my %sequence_hash2;

#................................
#MAIN
#................................
&FASTAfile;
#-------- read in FRHIT Results-------------
open(FASTA3, $ARGV[2]) or die "unable to open file,\n\t$help";
my ($frhit1, $frhit2);

while (<FASTA3>){
    my $line2 = $_;
    chomp $line2;
    if ($line2 =~ m/^(.*\/)\d\t.*/){
        $frhit1 = $1."1"; $frhit2 = $1."2";
        if($sequence_hash{$frhit1}){
            print OUT1 ">$frhit1\n";
            print OUT1 "$sequence_hash{$frhit1}\n";
            delete $sequence_hash{$frhit1}; #delete reads already stored
        
            print OUT2 ">$frhit2\n";
            print OUT2 "$sequence_hash2{$frhit2}\n";
            delete $sequence_hash{$frhit2}; #delete reads already stored
        }
        else {next;}
    }
}
close(FASTA3);
print "*********end***************************\n";
close(OUT1);
close(OUT2);

exit;

#................................
#SUBROUTINE
#................................
sub FASTAfile {
    foreach my $l (0..1){
        open(FASTA, $ARGV[$l]) or die "Cannot open the file,\n\t$help";     #import fasta file
        my $sequencecheck = 0;
        while (<FASTA>){
            my $line = $_;
            chomp $line;
            if ($line =~ m/^>(.*\/\d)/) {
                $seq_id = $1;
                $sequencecheck = 1;
            }
            elsif ($sequencecheck == 1){
                $sequence = $line;
                $sequencecheck = 2;
            }
            if ($sequencecheck == 2){
                if ($l == 0){
                    $sequence_hash{$seq_id} = $sequence;
                    ($seq_id, $sequence) = ('','');
                    my $sequencecheck = 0;
                }
                else {
                    $sequence_hash2{$seq_id} = $sequence;
                    ($seq_id, $sequence) = ('','');
                    my $sequencecheck = 0;
                }
            }
        }
        close (FASTA);
        print "\n\nDone with hash table id and sequence\n\n";
    }
}
#................................
#END.
#................................
