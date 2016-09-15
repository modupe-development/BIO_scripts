#!/usr/bin/perl
use strict;
$|=1;

# - - - - - H E A D E R - - - - - - - - - - - - - - - -
# Submit batch BLAST queries.
my $a = "Input \"folder path\" then \"date tag\"";
# - - - - - U S E R   V A R I A B L E S - - - - - - - -
my $datetag = $ARGV[1];        # output file tag
my $folder  = $ARGV[0];  # location of 

# - - - - - G L O B A L  V A R I A B L E S  - - - - - -
my $blastshell = "#!/bin/sh
#PBS -r n
#PBS -l cput=6:00:00
#PBS -l walltime=6:00:00
#PBS -q short
#PBS -d $folder
#PBS -N ";

my @FFN;
my $contigcount;
my $torquename = "TORQUE-$datetag.txt";
open(TORQUE, ">$torquename");
close (TORQUE);

#--------------------------------------------------------
# - - - - - M A I N - - - - - - - - - - - - - - - - - -
#--------------------------------------------------------

print "\n\nSTART: Imagine all the people, living for today . . .  \n\n";

# 1. Get the list of FASTA FILES . . . . . .
&FindFastas($folder,\@FFN);

# 2. Set up job submission batches . . . .
foreach my $job (1..$contigcount)
{   my $RUNname = "B.contig-".$job;                         # define the queue job name
    my $inseq = shift(@FFN);                             # define the infile fasta
    my $outfile = "BLASTout-".$datetag."-".$job.".txt";  # define the output file
    
    open(OUT,">z-BLASTshell-$datetag.sh");
    print OUT $blastshell;
    print OUT "$RUNname\n\n";
    open (TORQUE, ">>$torquename");
    print OUT "/usr/local/blast-2.2.22/bin/megablast -d /usr/local/blast_db/nt -i $inseq -o $outfile -v 10 -b 0\n\n";
    print TORQUE "\n\n/usr/local/blast-2.2.22/bin/megablast -d /usr/local/blast_db/nt -i $inseq -o $outfile -v 10 -b 0\n";
    close(OUT);
    close(TORQUE);


        # Check queue limit . . . . .

    open(TORQUE, ">>$torquename");
    print `qsub z-BLASTshell-$datetag.sh >>$torquename`;
    close(TORQUE);

}


print "* * * *   D O N E   * * * * \n\n\n";

#--------------------------------------------------------
# - - - - - S U B R O U T I N E S - - - - - - - - - - -
#--------------------------------------------------------
sub FindFastas
{   my $path = shift(@_);
    my $fasta_array = shift(@_);
    # A. Get Genome FASTA files from folder . . . . .
    #    Build FFN array to contain all the genomes to be used 
    #        in the analyses. 
    opendir(GenDir,$path) or die "\n\n\nNADA $path !\n$a\n\n";
    my @GenFolders = readdir(GenDir);
    close(GenDir);
    
    $contigcount = 0;
    foreach my $genfile (@GenFolders) {	
	if ($genfile =~ m/.fa$/) {
	    my @test = split(" ",$genfile);
	    my $ending = pop(@test);
	    my $newword;
	    foreach my $single(@test){
		$newword .= $single."\\ ";
	    }
	    my $newfile = $newword.$ending;
	    open(TORQUE, ">>$torquename");
   	    print TORQUE "$newfile\n";
    	    close(TORQUE);            
	    push(@{$fasta_array},$folder . $newfile);
            $contigcount += 1;
        }
    }
    
    print "There are $contigcount files in this run.\n\n";
}

# - - - - - EOF - - - - - - - - - - - - - - - - - - -
