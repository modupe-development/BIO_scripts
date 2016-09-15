#!/usr/bin/perl -w

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL FOR split w/ specific or not paired fastq/fasta file.pl

=pod

=head1 NAME

$0 -- split a fastq or fasta paired file, maybe extracting specific reads or not.

=head1 SYNOPSIS

w_osplitpairedfile.pl --in1 parentpaired.fastq[.fasta][.gz] [--in2 specificreads.fastq[.fasta][.gz]] [--fasta]
                [--zip] [--help] [--manual]

=head1 DESCRIPTION

Accepts one/two fastq/fasta files. If the second file is present, the specific forward and reverse reads will be extracted from the first file.
The sequences extracted to the output fastq/fasta.
This handles only paired end reads properly.

=head2 FASTQ FORMAT

Default: Sequence name is all characters between beginning '@' and first space or '/'.  Also first 
character after space or '/' must be a 1 or 2 to indicate pair relationship.  
Compatible with both original Illumina (Casava version 1.7 and previous) and newer
(Casava >= 1.8) formatted headers:
  @B<HWUSI-EAS100R:6:73:941:1973#0>/I<1>
  @B<EAS139:136:FC706VJ:2:2104:15343:197393> I<2>:Y:18:ATCACG

=head2 FASTA FORMAT

Default: Sequence name is all characters between beginning '>' and first space or '/'.  Also first 
character after space or '/' must be a 1 or 2 to indicate pair relationship.  
Compatible with both original Illumina (Casava version 1.7 and previous) and newer
(Casava >= 1.8) formatted headers:
  >B<HWUSI-EAS100R:6:73:941:1973#0>/I<1>
  >B<EAS139:136:FC706VJ:2:2104:15343:197393> I<2>:Y:18:ATCACG
 
=head1 OPTIONS

=over 3

=item B<-a, --i, --in, --in1>=FILE

One input file must be specified (e.g. parent paired reads).  (Required) 

=item B<-b, --in2>=FILE

Specific reads you want extracted (e.g. broken paired reads).  (Optional) 

=item B<-f, --fasta>

If it in fasta format, default is fastq. (Optional)

=item B<-z, --zip>

Specify that input is gzipped fastq (output files will also be gzipped).  Slower, but space-saving.  (Optional)

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries (all standard in most Perl installs).
   IO::Compress::Gzip
   IO::Uncompress::Gunzip
   Getopt::Long
   File::Basename
   Pod::Usage

=head1 AUTHOR

Written by Modupe Adetunji, 
Center for Bioinformatics and Computational Biology Core Facility, University of Delaware.

=head1 REPORTING BUGS

Report bugs to amodupe@udel.edu

=head1 COPYRIGHT

Copyright 2012 MOA.  
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.  
This is free software: you are free to change and redistribute it.  
There is NO WARRANTY, to the extent permitted by law.  

Please acknowledge author and affiliation in published work arising from this script's 
usage <http://bioinformatics.udel.edu/Core/Acknowledge>.

=cut

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - U S E R  V A R I A B L E S- - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# CODE FOR w_osplitpairedfile.pl

use strict;
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use Getopt::Long;
use File::Basename;
use Pod::Usage;

#ARGUMENTS
my($in1,$in2,$end,$zip,$fasta,$help,$manual);

GetOptions (
                                "a|i|in|in1=s"  =>      \$in1,
                                "b|in2=s"       =>      \$in2,
                                "z|zip"         =>      \$zip,
                                "f|fasta"       =>      \$fasta,
                                "h|help"        =>      \$help,
                                "m|manual"      =>      \$manual);

# VALIDATE ARGS
pod2usage(-verbose  => 2)  if ($manual);
pod2usage( -verbose => 1 )  if ($help);
pod2usage( -msg  => "ERROR!  Required arguments -a and/or -b are not found.\n", -exitval => 2, -verbose => 1)  if (! $in1 );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# PARSE OUTPUT FILEBASE
my $out = fileparse($in1, qr /\.[^.]*/);
if ($in2){
   $out=fileparse($in2, qr/\.[^.]*(\.gz)?$/);
}
# FILE HANDLES
my ($DATA1,$DATA2,$OUT1,$OUT2);

# OPEN INPUT FILE(s)(in1 &/ in2)
if($zip) {
   $DATA1 = IO::Uncompress::Gunzip->new( $in1 ) or die "IO::Uncompress::Gunzip failed: $GunzipError\n";
   if($in2) {
      $DATA2 = IO::Uncompress::Gunzip->new( $in2 ) or die "IO::Uncompress::Gunzip failed: $GunzipError\n";
   }
}
else {
   open ($DATA1,$in1) || die $!;
   if($in2) {
      open ($DATA2,$in2) || die $!;
   }
}

#OPEN OUTPUT FILE(s)
if ($fasta){$end = "fasta";}else{$end = "fastq"}
if($zip){
   $OUT1 = IO::Compress::Gzip->new( "$out\_1.$end.gz" ) or die "IO::Compress::Gzip failed: $GzipError\n";
   $OUT2 = IO::Compress::Gzip->new( "$out\_2.$end.gz" ) or die "IO::Compress::Gzip failed: $GzipError\n";
}
else {
   open($OUT1, "> $out\_1.$end") or die $!;
   open($OUT2, "> $out\_2.$end") or die $!;
}

#HASH TABLES & VARIABLES
my (%IN1hash, %IN2hash);
my $request = 1;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##
#
if ($fasta){
   while (<$DATA1>) {
      if (/^>(\S+)[\/ ]1/) {
         if ($in2){$IN1hash{$1} = $_.<$DATA1>;} else {print $OUT1 $_.<$DATA1>;}
      }
      elsif (/^>(\S+)[\/ ]2/) {
         if ($in2){$IN2hash{$1} = $_.<$DATA1>;} else {print $OUT2 $_.<$DATA1>;}  
      }
   }
   if ($in2){
      while (<$DATA2>) {
         if (/^>(\S+)[\/ ][12]/) {
            if (exists $IN1hash{$1}){
               print $OUT1 $IN1hash{$1};
               print $OUT2 $IN2hash{$1};
               delete $IN1hash{$1};
               delete $IN2hash{$1};
            }
         }
      }
      close $DATA2;
   }
} else {
   while (<$DATA1>) {
      if (/^@(\S+)[\/ ]1/ && $request == 1) {
         if ($in2){$IN1hash{$1} = $_.<$DATA1>.<$DATA1>.<$DATA1>;} else {$request = 0; print $OUT1 $_.<$DATA1>.<$DATA1>.<$DATA1>;}
      }
      elsif (/^@(\S+)[\/ ]2/ && $request == 0) {
         if ($in2){$IN2hash{$1} = $_.<$DATA1>.<$DATA1>.<$DATA1>;} else {$request = 1; print $OUT2 $_.<$DATA1>.<$DATA1>.<$DATA1>;}  
      }
   }
   if ($in2){
      while (<$DATA2>) {
         if (/^@(\S+)[\/ ][12]/) {
            if (exists $IN1hash{$1}){
               print $OUT1 $IN1hash{$1};
               print $OUT2 $IN2hash{$1};
               delete $IN1hash{$1};
               delete $IN2hash{$1};
            }
         }
      }
      close $DATA2;
   }
}
         
close $DATA1; close $OUT1; close $OUT2;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

