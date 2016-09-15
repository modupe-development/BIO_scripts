#!/usr/bin/perl -w

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL FOR renaming the grinder headers to unique numbers.pl

=pod

=head1 NAME

$0 -- rename grinder headers (only replacing "reference" with unique numbers).

=head1 SYNOPSIS

renamingtheheaders.pl --in1 parentpaired.fastq [--zip] [--help] [--manual]

=head1 DESCRIPTION

Accepts one fastq files.
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
my($in1,$in2, $help,$manual, $fasta);
GetOptions (
                                "a|i|in|in1=s"  =>      \$in1,
                	        "2|in2=s" 	=>      \$in2,
                                "f|fasta"       =>      \$fasta,
		                "h|help"        =>      \$help,
                                "m|manual"      =>      \$manual);

# VALIDATE ARGS
pod2usage(-verbose  => 2)  if ($manual);
pod2usage( -verbose => 1 )  if ($help);
pod2usage( -msg  => "ERROR!  Required arguments -a are not found.\n", -exitval => 2, -verbose => 1)  if (! $in1 );

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# FILE HANDLES
my ($DATA,$OUT);
my $out=fileparse($in1, qr/\.[^.]*(\.gz)?$/);
my $output = "$out-renamed.fastq"; if($fasta){$output = "$out-renamed.fasta";} # OPEN INPUT FILE in1
open ($DATA,$in1) || die $!;
#OPEN OUTPUT FILE(s)
open($OUT, ">$output") or die $!;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##
#
my $header; my $number = 1; #renumber the reads (changing "reference" to numbers)
while (<$DATA>) {
   if ($fasta){
        if (/^>\S+/){  
            $header = "\>Ara_thi_clc_contigs-$number/0";
            $number++;
        } 
	if (/^[ATGCN].*/){
            my $length = length($_)-1;
            $header = "$header\_$length\n";
            print $OUT $header.$_;
        }
   } else {
   	if (/^@(\S+)\_(\d+)$/){   #for pbsim output fastq
       	    $header = "\@m111006_202713_42141_c100202382555500000315044810141104_f1_p0/$number/0";
            $number++;
   	} if (/^[ATGCN].*/){
            my $length = length($_)-1;
            $header = "$header\_$length\n";
            print $OUT $header.$_.<$DATA>.<$DATA>;
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


