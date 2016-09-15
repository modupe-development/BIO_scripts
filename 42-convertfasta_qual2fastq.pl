#!/usr/bin/perl -w

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL FOR convertfasta2fastq.pl

=pod

=head1 NAME

$0 -- convert fasta and qual file to fastq

=head1 SYNOPSIS

convertfasta2fastq.pl --in1 fasta.fa[.gz] [--in2 qual.qual[.gz]] 
		[--zip] [--help] [--manual]

=head1 DESCRIPTION

Accepts a fasta file and a quality file to create a fastq file,
based on your fasta file provided.

=head2 FASTQ FORMAT

Default: Sequence name is all characters between beginning '@' and the quality name will begin with '+'

=head1 OPTIONS

=over 3

=item B<-1, -f, --in1>=FILE

The fasta file must be specified (e.g. fasta reads file).  (Required) 

=item B<-2, -q, --in2>=FILE

THe quality file must be specified (e.g. quality file).  (Required) 

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

# CODE FOR fastq-random-sample.pl

use strict;
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use Getopt::Long;
use File::Basename;
use Pod::Usage;

#ARGUMENTS
my($in1,$in2,$zip,$help,$manual);

GetOptions (	
				"1|f|in1=s"	=>	\$in1,
				"2|q|in2=s"	=>	\$in2,
				"z|zip" 	=>	\$zip,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose  => 2)  if ($manual);
pod2usage( -verbose => 1 )  if ($help);
pod2usage( -msg  => "ERROR!  Required arguments -1 and/or -2 are not found. \n", -exitval => 2, -verbose => 1)  if (! $in1 || ! $in2 );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# PARSE OUTPUT FILEBASE
my $out1=fileparse($in1, qr/\.[^.]*(\.gz)?$/);

# FILE HANDLES
my ($DATA1,$DATA2,$OUT1);

# OPEN INPUT FILE(s)(in1 &/ in2)
if($zip) {
   $DATA1 = IO::Uncompress::Gunzip->new( $in1 ) or die "IO::Uncompress::Gunzip failed: $GunzipError\n";
   $DATA2 = IO::Uncompress::Gunzip->new( $in2 ) or die "IO::Uncompress::Gunzip failed: $GunzipError\n";
}
else {
   open ($DATA1,$in1) || die $!; open ($DATA2,$in2) || die $!;
}

#OPEN OUTPUT FILE(s)
if($zip){
   $OUT1 = IO::Compress::Gzip->new( "$out1-new.fastq.gz" ) or die "IO::Compress::Gzip failed: $GzipError\n";
}
else {
   open ($OUT1,"> $out1-new.fastq") or die $!;
}

# REG EXP FOR HEADERS
my $hdr_ptrn='^\>(.+)$';
#HASH TABLES & VARIABLES
my (%INhash, %IN1hashdetails, %IN2hashdetails); my $uid=0;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##
## PROCESS in1
#

while(<$DATA1>) {
   if (/$hdr_ptrn/){
      $IN1hashdetails{$1}="\@$1\n";
      $IN1hashdetails{$1}.=<$DATA1>;
      $uid++;
   }
   else {
      die "ERROR! File format error in $in1 near line ".$..".\n$_\n";
   }
}
close $DATA1;
print "Computed fasta reads = $uid\n";

##
## PROCESS in2 for paired reads (optional)
#
$uid=0;
while(<$DATA2>){
   if (/$hdr_ptrn/){
      if ($IN1hashdetails{$1}){
         $INhash{$uid} = $1;
         $IN2hashdetails{$1}="\+$1\n";
	 $IN2hashdetails{$1}.=<$DATA2>;
         $uid++;
      }
   }
}
close $DATA2;
print "Computed quality reads = $uid\n";

#OUTPUT FASTQ READS
foreach my $no (1..$uid){
   my $check = 1;
   my $s_header = '';
   my $s_uid = '';
   while ($check == 1){
      $s_uid = int(rand($uid));
      if (exists $INhash{$s_uid}){
         $s_header = $INhash{$s_uid};
         delete $INhash{$s_uid};
         $check = 0;
      }
   }
   print $OUT1 "$IN1hashdetails{$s_header}";
   print $OUT1 "$IN2hashdetails{$s_header}";
}
close $OUT1;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

