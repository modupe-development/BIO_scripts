#!/usr/bin/perl
use strict;
$|=1;

# - - - - - H E A D E R - - - - - - - - - - - - - - - -
# Submit batch BLAST queries.

# - - - - - U S E R   V A R I A B L E S - - - - - - - -
my $datetag = "09MAY";        # output file tag
my $folder  = "02-Genomes/";  # location of 
my $JOBS    = 25;             # number of jobs to submit

# - - - - - G L O B A L  V A R I A B L E S  - - - - - -
my $blastshell = "#!/bin/sh
#PBS -r n
#PBS -j oe
#PBS -l cput=6:00:00
#PBS -l walltime=6:00:00
#PBS -q short
#PBS -d /home/marsh/99-mast697/
#PBS -N ";

my @FFN;


#--------------------------------------------------------
# - - - - - M A I N - - - - - - - - - - - - - - - - - -
#--------------------------------------------------------

print "\n\nSTART: Imagine all the people, living for today . . .  \n\n";

# 1. Get the list of FASTA FILES . . . . . .
&FindFastas($folder,\@FFN);

# 2. Set up job submission batches . . . .
foreach my $job (1..$JOBS)
{   my $RUNname = "Bpuke-".$job;                         # define the queue job name
    my $inseq = shift(@FFN);                             # define the infile fasta
    my $outfile = "BLASTout-".$datetag."-".$job.".txt";  # define the output file
    
    open(OUT,">z-BLASTshell.sh");
    print OUT $blastshell;
    print OUT "$RUNname\n\n";
    print OUT "/usr/local/blast-2.2.22/bin/blastall -p blastn -d /usr/local/blast_db/nt -i $inseq -o $outfile -e 1e-3 -m 8 -v 20 -b 20\n\n";
    close(OUT);
	
	# Check queue limit . . . . .
	
	
    print `qsub z-BLASTshell.sh`;
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
    opendir(GenDir,$path) or die "\n\n\nNADA $path you fool!\n\n\n";
    my @GenFolders = readdir(GenDir);
    close(GenDir);
    
    my $gcount = 0;
    foreach my $genfolder (@GenFolders)
    {	if ($genfolder =~ m/^[A-Z].*uid\d{5}/)
        {	$genfolder = $folder . $genfolder;
            opendir(FFN,$genfolder) or die "\n\n\nNADA $genfolder\n\n\n";
            my @files = readdir(FFN);
            close(FFN);
            push(@{$fasta_array},$genfolder . "/" . $files[2]);
            $gcount += 1;
        }
    }
    
    print "There are $gcount genomes in this run.\n\n";
}

# - - - - - EOF - - - - - - - - - - - - - - - - - - -