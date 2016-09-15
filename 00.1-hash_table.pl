#!/usr/bin/perl 
use strict;

open(FASTA, $ARGV[0]) or die "cannot open fasta file";     #import fasta file

my $seq_id;
my $sequence;
my %sequence_hash;

my $seqExtraction = "/home/amodupe/SeqExtraction.fna";
my $qualExtraction = "/home/amodupe/QualExtraction.fna";

while (<FASTA>)
{
    my $line = $_;
    chomp $line;
    if ($line =~ m/^>(\S+)\s?/)                       ## putting the sequence ID into a buffer - $1 ... Needed to add '>' so it doesn't put the '>' sign into the buffer
    {
        
        if ($seq_id) {                              ## first time you go thru seq_id does not exist, we won't do this part
            $sequence_hash{$seq_id} = $sequence;    ## seq_id is key, sequence is value
            $seq_id ='';                            ## clearing out seq_id and sequence
            $sequence ='';                          ##
            
        }
        $seq_id = $1;                               ## Everything int he buffer is going into seq_id now.
           
    }
    else {                                      ##
        $sequence .= $line;
        
        }
}
$sequence_hash{$seq_id} = $sequence;                ## Last sequence it'll read the sequence in then encounter the end of file (EOF) so this will add it.
close(FASTA);
print "\n";
print "here";

open(QUALITY, $ARGV[1]) or die "cannot open quality file";     #import fasta file

my $quality_id;
my $quality;
my %quality_hash;

while (<QUALITY>)
{
    my $line1 = $_;
    chomp $line1;
    if ($line1 =~ m/^>(\S+)\s?/)                       ## putting the sequence ID into a buffer - $1 ... Needed to add '>' so it doesn't put the '>' sign into the buffer
    {
        
        if ($quality_id) {                              ## first time you go thru seq_id does not exist, we won't do this part
            $quality_hash{$quality_id} = $quality;    ## seq_id is key, sequence is value
            $quality_id ='';                            ## clearing out seq_id and sequence
            $quality ='';                          ##
            
        }
        $quality_id = $1;                               ## Everything int he buffer is going into seq_id now.
           
    }
    else {    if ($quality)
          {$quality = " ";
        $quality .= $line1;

        }
}
}
$quality_hash{$quality_id} = $quality;                ## Last sequence it'll read the sequence in then encounter the end of file (EOF) so this will add it.

print "\n";
print "end of quality file processing";
close(QUALITY);

open(OUT1, ">$seqExtraction");  #should contain name and sequence
open(OUT2, ">$qualExtraction"); 

#----- in-puts FRHIT results and converts it to an array with just sequence id----------

open(FRHIT, $ARGV[2]);

my $index = 0;
my $frhit;


while (<FRHIT>)
{ my $line2 = $_;
 chomp $line2;
   
if ($line2 =~ m/^(\S+)\s?/)    
   { $frhit = $1;
  print OUT1 ">$frhit\n";
  print OUT1 "$sequence_hash{$frhit}";
  print OUT1 "\n";
  print OUT2 ">$frhit\n";
  print OUT2 "$quality_hash{$frhit}";
  print OUT2 "\n";
  }
}



close(FRHIT);
close OUT1;
close OUT2;
print "\n";
print "end of FRHIT file in-put";

print "end";


