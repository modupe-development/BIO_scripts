#!/usr/bin/perl -w

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL FOR cleaning the errors in the grinder output for simulated data 

=pod

=head1 NAME

$0 -- split a fastq or fasta paired file, maybe extracting specific reads or not.

=head1 SYNOPSIS

cleaninggrinderoutput.pl --in1 parentpaired.fastq[.fasta][.gz] [--zip] [--help] [--manual]

=head1 DESCRIPTION

Accepts one fastq file and looks through each line of the file to make sure the right information is present.
This handles single and paired end reads properly.

=head2 FASTQ FORMAT

Default: Sequence name is all characters between beginning '@' and first space or '/'.  Also first 
character after space or '/' must be a 1 or 2 to indicate pair relationship.  
Compatible with both original Illumina (Casava version 1.7 and previous) and newer
(Casava >= 1.8) formatted headers:
  @B<HWUSI-EAS100R:6:73:941:1973#0>/I<1>
  @B<EAS139:136:FC706VJ:2:2104:15343:197393> I<2>:Y:18:ATCACG
 
=head1 OPTIONS

=over 3

=item B<-a, --i, --in, --in1>=FILE

One input file must be specified (e.g. parent paired reads).  (Required) 

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries (all standard in most Perl installs).
   Getopt::Long
   File::Basename
   Pod::Usage

=head1 AUTHOR

Written by Modupe Adetunji, 
Center for Bioinformatics and Computational Biology Core Facility, University of Delaware.

=head1 REPORTING BUGS

Report bugs to amodupe@udel.edu

=head1 COPYRIGHT

Copyright 2013 MOA.  
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.  
This is free software: you are free to change and redistribute it.  
There is NO WARRANTY, to the extent permitted by law.  

Please acknowledge author and affiliation in published work arising from this script's 
usage <http://bioinformatics.udel.edu/Core/Acknowledge>.

=cut

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - U S E R  V A R I A B L E S- - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# CODE FOR cleaninggrinderoutput.pl

use strict;
use Getopt::Long;
use File::Basename;
use Pod::Usage;

#ARGUMENTS
my($in1,$fasta,$help,$manual);
my $array = '';
GetOptions (
                                "a|i|in|in1=s"  =>      \$in1,
                                "h|help"        =>      \$help,
                                "m|manual"      =>      \$manual);

# VALIDATE ARGS
pod2usage(-verbose  => 2)  if ($manual);
pod2usage( -verbose => 1 )  if ($help);
pod2usage( -msg  => "ERROR!  Required arguments -a and/or -b are not found.\n", -exitval => 2, -verbose => 1)  if (! $in1 );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# FILE HANDLES
my $DATA1;
my $output = "/home/amodupe/datastore/Populus_trichocarpa-new.fastq";
# OPEN INPUT FILE in1
open ($DATA1,$in1) || die $!;

#OPEN OUTPUT FILE(s)
open(OUT, ">$output") or die $!;
close (OUT);

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##
#
my ($sequence, $quality, $number, $initialize) = (0,0,0,0); #line where the problem in the fastq file is.
while (<$DATA1>) {
   $number++;
   if (/^@\S+.*$/ && $sequence == 0 && $quality == 0){
      my $name = $_;
      if ($name !~ /^.+.*(@\d.*)$/) {
      	    $array = $_;
      	    $sequence = 1;
      }
      else {
	  $array = "$1\n";
	  $sequence = 1;
      }
   }
   elsif (/^[ATGCN]/ && $sequence == 1 && $quality == 0) {
      my $seqread = $_;
      if ($seqread !~ /^[ATGCN].*(@\d.*)$/) {
	  if ($initialize == 1) {
	      $array = $_;
	      $sequence = 2;
	      $initialize = 0;
	  } else {
	      $array .= $_;
	      $sequence = 2;
	  }
      }
      else {
          $array = "$1\n";
          $sequence = 1;
      }
   }
   elsif (/^\+$/ && $sequence == 2 && $quality == 0) {
      $array .= $_;
      $quality = 1;
   }
   elsif (/^[\+D]+/ && $quality == 1 && $sequence == 2) {
      my $qualread = $_;
      if ($qualread !~ /^[\+D]+.*(@\d.*)$/) {
            $array .= $_;
            $sequence = 0;
	    $quality = 0;
      }
      else {
          $array .= "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD\n$1\n";
          $initialize = 1;
	  $sequence = 1;
	  $quality = 0;
      }
      open (OUT, ">>$output"); print OUT $array; close (OUT); 
   }
   else {
      print "line number = $number\n";
      print $_;
      print "fault\n";
      exit;
   }
}
         
close $DATA1; close OUT;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

