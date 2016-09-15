#!/usr/bin/perl

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL FOR renaming the grinder headers to unique numbers.pl

=pod

=head1 NAME

$0 -- rename grinder headers (only replacing "reference" with unique numbers).

=head1 SYNOPSIS

renamingtheheaders.pl --in1 parentpaired.fastq [--fasta] [--pacbiotoca] [--zip] [--help] [--manual]

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

=item B<-f, --fasta>

If your inputfile is in fasta format.  (Optional)

=item B<-p, --pacbiotoca>

If your inputfile is a pacbiotoca fastq file.  (Optional)

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
my($in1,$in2, $help,$manual, $fasta, $pacbiotoca);
GetOptions (
                                "a|i|in|in1=s"  =>      \$in1,
                	        "2|in2=s" 	=>      \$in2,
                                "f|fasta"       =>      \$fasta,
                                "p|pacbiotoca"  =>      \$pacbiotoca,
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
my ($DATA,$OUT, $OUT2);

#NAMING OUTPUT FILE
my $out=fileparse($in1, qr/\.[^.]*(\.gz)?$/);
my $output = "$out-renamed.fastq"; if($fasta){$output = "$out-renamed.fasta";}
my $log = "$out-renamed.log"; 
#VARIABLES
my %HEADERNAME;
my %QUERY = '';
my ($header, $number, $originalname, $pbecname, $oripbecname);

#OPEN FASTQ FILE
open ($DATA,$in1) || die $!;
#OPEN OUTPUT FILE(s)
open($OUT, ">$output") or die $!;
open($OUT2, ">$log") or die $!;
print $OUT2 "ORIGINAL NAME\tNEW GAA NAME\n";

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##
#
if($pacbiotoca){
	$number=0; #renumber the reads (changing "reference" to numbers)
	open ($DATA,$in1) || die $!;
	while (<$DATA>){
                if (/^@.*$/){   #for all fastq
			my @lines = split("\/", $_);
	                $lines[0] =~/^@(.*)_(\d)$/;
        	        $originalname = $1;
                	my @array = ($originalname, $2);
                	unless (exists $QUERY{$originalname}){
                                $number++;
				$QUERY{$originalname} = $number;
                        }
			$HEADERNAME{$lines[0]} = [ @array ];
		}
        }
	#my $count=1; foreach (keys %QUERY){$count++; print "$_\t$QUERY{$_}\n";}
	#print "$count\n"; die;
	close $DATA;
	open ($DATA,$in1) || die $!;
	while (<$DATA>) {
                if (/^@.*$/){  
                        my @lines = split("\/", $_);
                        $lines[0] =~/^@(.*)_(\d)$/;
                        $oripbecname = $lines[0];
			$pbecname = $1;
			$header = "\@Contig$QUERY{$pbecname}\.$HEADERNAME{$lines[0]}[1]\n";
                }
                if (/^[ATGCN].*/){
                        my $length = length($_)-1;
                        print $OUT $header.$_.<$DATA>.<$DATA>;
			print $OUT2 "$oripbecname\t$header\n";
                }
	}
	close $DATA; close $OUT;
} else {
	my $addressname;
	$number = 1;
	open ($DATA,$in1) || die $!;
	while (<$DATA>) {
		if ($fasta){
	        	if (/^(>\S+)/){ #for all fasta  
        			$addressname = $1;
				$header = "\>Contig$number\.1\n";
			        $number++;
        		} 
			if (/^[ATGCN].*/){
	        		my $length = length($_)-1;
			        print $OUT $header.$_;
				print $OUT2 "$addressname\t$header\n";

        		}
	   	} else {
   			if (/^(@\S+)/){   #for all fastq
       				$addressname = $1;
				$header = "\@Contig$number\.1\n";
            			$number++;
	   		} 
			if (/^[ATGCN].*/){
            			my $length = length($_)-1;
            			print $OUT $header.$_.<$DATA>.<$DATA>;
				print $OUT2 "$addressname\t$header\n";
	   		}
   		}
	}
	close $DATA; close $OUT;
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
