#!/usr/bin/perl -w

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL FOR making sure only paired reads are present.pl

=pod

=head1 NAME

$0 -- checks through the file to make sure that only reads with pairs are stored.

=head1 SYNOPSIS

makingsureonlypairedreadspresent.pl --in1 parentpaired.fastq  [--zip] [--help] [--manual]

=head1 DESCRIPTION

Accepts one fastq files. It checks through the file to make sure that only reads with pairs are stored,
while the others that don't have pairs are discarded.
The sequences extracted to the output fastq.
This handles only paired end reads properly.

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

# CODE FOR renamingtheheaders.pl

use strict;
use Getopt::Long;
use File::Basename;
use Pod::Usage;

#ARGUMENTS
my($in1,$help,$manual);
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
my ($DATA,$OUT);
my $output = "/home/amodupe/datastore/Populus_trichocarpa-edit.fastq";
# OPEN INPUT FILE in1
open ($DATA,$in1) || die $!;

#OPEN OUTPUT FILE(s)
open($OUT, ">$output") or die $!;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##
#
my ($header1, $header2) = (0,0); #header numbers
my ($array1, $array2);
while (<$DATA>) {
      if (/^@(\d+)[\/ ].*$/ && $header1 == 0) {
         $header1= $1;
         $array1=$_.<$DATA>.<$DATA>.<$DATA>;
      }
      elsif (/^@(\d+)[\/ ].*$/ && $header1 != 0) {
         $header2 =$1;
         $array2=$_.<$DATA>.<$DATA>.<$DATA>;
      }
      if ($header1 != 0 && $header2 != 0){
        unless ($header1==$header2){
          print "variable1 = $header1\nvariable2 = $header2";
          $array1 = $array2;
          $header1 = $header2; $header2=0;
        }
        else {
         print $OUT "$array1$array2";print "$header1\t$header2\nyes\t";
        #initialize
        $header1 = 0; $header2 = 0;
	}
     }
}

close $DATA; close $OUT;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

