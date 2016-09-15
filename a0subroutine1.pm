#!usr/bin/perl
#subroutines

use strict;

#=======================================================================
#1. Importing ASCII into a dictionary
#2. Getting sequence name, sequence and quality scores from FASTQ file
#===========================================================================



#importing ascii into the hash dictionary
#========================================
sub ASCII {
    my ($Quality) = @_;
    #creating the dictionary
    my %ASCII ='';
    #======opening the file
    my $filename = 'asciidata.ascii';
    unless (open (ASCII, $filename)){
        print "File $filename doesn't exist";
        exit;
    }
    my @ascii = <ASCII>;
    close (ASCII);
    foreach my $line (@ascii){
    #creating the dictionary
        $line =~ m/(\S+)\s(\S+)/;
        
        #my @line = split( " ", $line);
        #my $key = $line[1];
        #my $values = $line[0];
        #$ASCII{$key} = $values;
        
        $ASCII{$2} = $1;
    }
}


#getting sequence name, sequence and quality scores from FASTQ file
#==================================================================
sub GETFASTQ {
    my ($files) = @_;
    #print $files;
    unless(open (FILE , $files)){
        print "File doesn't exist";
    }
    my @file = <FILE>;
    chomp @file;
    close (FILE);
    my $seq = '';					#<--- the nucleotide sequence
    my $seqquality = '';			#<--- the quality scores
    my $seqname = $file[0];			#<--- the sequence name
    foreach my $line (@file) {
        chomp $line;
        if ($line =~ /^@/){			#<--- removing all the sequence name
            next;	
        }elsif ($line =~ /^\+/){		#<--- removing all the sequence name for the quality scores
            next;
        }elsif ($line =~ /^[AGCTN]/) {	#<--- adding all the nucleotide sequences together
            $seq .= $line; 
        }else {
            $seqquality .=$line;		#<--- adding all the quality scores together
        }
    }
    
    #printing out the sequences of each FASTQ file
    #print "$seqname\n\n";
    #print substr($seq,0,20),"\n";
    #print substr($seqquality,0,20),"\n\n\n";
    
	return $seqname, $seq, $seqquality; 
 }
1;
