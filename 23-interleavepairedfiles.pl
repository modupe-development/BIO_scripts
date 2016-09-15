#!/usr/bin/perl -w

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL FOR creating a paired file from the split files.pl

=pod

=head1 NAME

$0 -- paired the split forward & reverse reads of a fastq / fasta files to one paired file.

=head1 SYNOPSIS

interleavepairedfiles.pl --in1 fwd.fastq[.fasta][.gz] --in2 rev.fastq[.fasta][.gz] [--fasta]
                [--zip] [--help] [--manual]

=head1 DESCRIPTION

Accepts two fastq/fasta files. Interleaves the forward and reverse reads together.
The sequences are extracted to an output fastq/fasta.
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

=item B<-1, --in1>=FILE

forward reads file must be specified (e.g. forward reads).  (Required) 

=item B<-2, --in2>=FILE

reverse reads file must be specified (e.g. reverse reads).  (Required) 

=item B<-f, --fasta>

If it in fasta format. (Optional)

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

# CODE FOR fastq-random-sample.pl

use strict;
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use Getopt::Long;
use File::Basename;
use Pod::Usage;

#ARGUMENTS
my($in1,$in2,$end, $zip,$fasta,$help,$manual);

GetOptions (
                                "1|in1=s"    =>      \$in1,
                                "2|in2=s"       =>      \$in2,
                                "z|zip"         =>      \$zip,
                                "f|fasta"       =>      \$fasta,
                                "h|help"        =>      \$help,
                                "m|manual"      =>      \$manual);

# VALIDATE ARGS
pod2usage(-verbose  => 2)  if ($manual);
pod2usage( -verbose => 1 )  if ($help);
pod2usage( -msg  => "ERROR!  Required arguments -1 and/or -2 are not found.\n", -exitval => 2, -verbose => 1)  if (! $in1 || ! $in2 );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# PARSE OUTPUT FILEBASE
my $out = fileparse($in1, qr/\.[^.]*(\.gz)?$/);

# FILE HANDLES
my ($DATA1,$DATA2,$OUT);

# OPEN INPUT FILE(s)(in1 &/ in2)
if($zip) {
   $DATA1 = IO::Uncompress::Gunzip->new( $in1 ) or die "IO::Uncompress::Gunzip failed: $GunzipError\n";
   $DATA2 = IO::Uncompress::Gunzip->new( $in2 ) or die "IO::Uncompress::Gunzip failed: $GunzipError\n";
}
else {
   open ($DATA1,$in1) || die $!;
   open ($DATA2,$in2) || die $!;
}

#OPEN OUTPUT FILE(s)
if ($fasta){$end = "fasta";}else{$end = "fastq"}
if($zip){
   $OUT = IO::Compress::Gzip->new( "$out.paired.$end.gz" ) or die "IO::Compress::Gzip failed: $GzipError\n";
}
else {
   open($OUT, "> $out.paired.$end") or die $!;
}

#HASH TABLES & VARIABLES
my (%IN1hash, %IN2hash, $uid);

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##
#
if ($fasta){
   while (<$DATA1>) {
      if (/^>(\S+)[\/ ]1/) {$IN1hash{$1} = $_.<$DATA1>;}
   }
   while (<$DATA2>){
      if (/^>(\S+)[\/ ]2/) {$IN2hash{$1} = $_.<$DATA2>;}
   }
} else {
   while (<$DATA1>) {
      if (/^@(\S+)[\/ ]1/) {$IN1hash{$1} = $_.<$DATA1>.<$DATA1>.<$DATA1>;}
   }
   while (<$DATA2>){
      if (/^@(\S+)[\/ ]2/) {$IN2hash{$1} = $_.<$DATA2>.<$DATA2>.<$DATA2>;}
   }
}
foreach (keys %IN1hash){
   if ($_ =~ /\S+/){
      print $OUT "$IN1hash{$_}";
      print $OUT "$IN2hash{$_}";
   }
}
         
close $DATA1; close $DATA2; close $OUT;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

