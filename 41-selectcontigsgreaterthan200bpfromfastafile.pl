#!/usr/bin/perl
use strict;

# - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
#
# Objective: Creating a GeneProfile for all the list of Genes
#	in the Human Genome.
# FINAL-MAST697
# MOA 5/12/2012
#

# - - - - - U S E R    V A R I A B L E S  - - - - - - - - - -
my $readsgenome = $ARGV[0];
my @NT = qw | T C A G N |;
my $Countinggenes=0; #Counting the number of genes in the human genome file
my $codinggenecount = 0;	#the total number of valid coding genes
my %iub2character_class;
# - - - - - G L O B A L  V A R I A B L E S  - - - - - - - - -

my %SEQ;
my %COUNT;

#The output file
my $outfile2 = "contigs200.fasta";
open(OUT2, ">$outfile2");
close (OUT2);


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - M A I N - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print "\n\n\nStarting . . . . \n"; 
# B. Loading the conversion to regular expression dictionary

# C. ANALYTICAL SECTION ...    
# 1. Read Fasta ....
&FASTAREAD($readsgenome);

#2. Calculate &GC ...
foreach my $gene (keys %SEQ){
    foreach my $nt (@NT){$COUNT{$nt} = 0;}
    my $seq = $SEQ{$gene}; #the sequence of each genome
    my $len = length($seq);
    $Countinggenes++; #counting all the gene in the file
    
    #B. For single nucleotide calculation...
	my @s = split('', $seq);
	foreach my $nt (@s){
	    $COUNT{$nt} ++;
	}	
    #F. file greter than 200bp
	if ($len > 199) {
	    $codinggenecount ++; #counting the gene that passed the filter test
	    open (OUT2, ">>$outfile2");
            print OUT2 ">$gene\n$seq\n";
	    close (OUT2);
	}
}
print "\n\nGenome Analysis Complete.\nThere are $Countinggenes genes in the human genome file. \n\n";
print "\n\nHowever. . .\n\tThere were a total of $codinggenecount valid coding genes in the human genome. \n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 1. To read each fastafile
sub FASTAREAD {
    $/ = ">";
    %SEQ = ();
    open(FASTA, "<$_[0]") or die "\n\n\nNada $_[0]\n\n\n"; 
    my @fastaFILE = <FASTA>;
    close (FASTA);
    shift (@fastaFILE);
    foreach my $entry(@fastaFILE){
        my @pieces = split(/\n/, $entry);
        my $header = "$pieces[0]";
        my $seqnum = '';
	my $seq = '';
	foreach my $num (1..$#pieces){
	    $seqnum .= $pieces[$num];
	}
	    #coverting to uppercase 
	    $seqnum = uc($seqnum);
	    my @nucleotides = split('',$seqnum);
            pop (@nucleotides);
	    foreach my $nT (@nucleotides){
               $seq .= $nT;
            }
	#saving the results into the dictionary &SEQ
        $SEQ{$header} = $seq;
    }
    $/ = "\n";
}
#---------------------
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
