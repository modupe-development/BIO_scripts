#!/usr/bin/perl

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MANUAL FOR renaming the grinder headers to unique numbers.pl

=pod

=head1 NAME

$0 -- rename grinder headers (only replacing "reference" with unique numbers).

=head1 SYNOPSIS

joiningPACBIOTOCAcontigs.pl --logfile pacbiotoca.log --fastq pacbiotoca.fastq [--help] [--manual]

=head1 DESCRIPTION

Accepts the pacbiotoca log and pacbiotoca fastq file.
The sequences are extracted and joined based on their log details 
and the gaps are filled with Ns.

=head1 OPTIONS

=over 3

=item B<-l, --logfile>=FILE

The pacbiotoca log file must be specified (e.g. pacbiotoca.log).  (Required)

=item B<-f, --fastqfile>=FILE

The pacbiotoca fastq file must be specified (e.g. pacbiotoca.fastq).  (Required)

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

Copyright 2014 MOA.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please acknowledge author and affiliation in published work arising from this script's
usage <http://bioinformatics.udel.edu/Core/Acknowledge>.

=cut

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - U S E R  V A R I A B L E S- - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# CODE FOR joiningPACBIOTOCAcontigs.pl

use strict;
use Getopt::Long;
use File::Basename;
use Pod::Usage;

#ARGUMENTS
my($logfile,$fastq,$help,$manual);

GetOptions (
                                "l|logfile=s"       =>      \$logfile,
                                "f|fastq=s"         =>      \$fastq,
                                "h|help"        =>      \$help,
                                "m|manual"      =>      \$manual);

# VALIDATE ARGS
pod2usage(-verbose  => 2)  if ($manual);
pod2usage( -verbose => 1 )  if ($help);
pod2usage( -msg  => "ERROR!  Required argument -l & -f is not found.\n", -exitval => 2, -verbose => 1)  if (! $logfile || ! $fastq );

my %location;
my %SEQlist;
my %QUAlist;
my ($INPUT, $DATA, $OUT, $out);
my $originalname;

#OUTPUT file
$out=fileparse($fastq, qr/\.[^.]*(\.gz)?$/);
open ($OUT,">$out-joint.fastq") or die $!;


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - -
# - - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - - -- - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#OPEN LOG FILE
open($INPUT,$logfile) || die $!;
while (<$INPUT>){
	unless (/^INPUT.*/){ #to remove the column names
	 	my @lines = split("\t", $_);
		$lines[1] =~/(.*)_(\d)$/;
	        $originalname = $1;
		my @position = ($originalname, $lines[3],$lines[4],$lines[5]);
		$location{$lines[1]} = [ @position ];
	}
}
close $INPUT;
my @sort = sort { $a cmp $b || $a <=> $b } keys %location;


#OPEN FASTQ FILE 
open ($DATA,$fastq) || die $!;
my $sequence = 0; my $quality = 0; 
my ($header, $nucseqs);
while (<$DATA>) {
	if (/^@(\S+.*)$/ && $sequence == 0 && $quality == 0){
      		$1 =~ /^(\S+)\/.*/;
		$header = $1;
	 	$sequence = 1;
   	}
   	elsif ($sequence == 1 && $quality == 0) {
      		$nucseqs = $_;
      		$sequence = 2;
   	}
   	elsif (/^\+/ && $sequence == 2 && $quality == 0) {
      		$quality = 1;
   	}
   	elsif ($quality == 1 && $sequence == 2) {
      		$SEQlist{$header} = $nucseqs;
		$QUAlist{$header} = $_;
		$quality = 0;
      		$sequence = 0;
   	}
}
close $DATA;

#joining the cut contigs
my $detritus; my $newname; my $identity;
foreach (keys %location){
	my $n_start = 0;
	my $n_end = 0;
	my $name = $location{$_}[0];
	for (my $i=1 ; $i<20; $i++){
		$newname = $name."_$i";
		if (exists $location{$newname}){
			if ($i == 1){ 
				$detritus = $SEQlist{$newname}; delete $SEQlist{$newname};
				$identity = $QUAlist{$newname}; delete $QUAlist{$newname};
				$n_start = $location{$newname}[2];
				chomp $detritus; chomp $identity;
			} 
			else { 
				$n_end = $location{$newname}[1];
				my $Ns = $n_end - $n_start;
				$n_start = $location{$newname}[2];
				foreach (1..$Ns) { $detritus .= "N"; $identity .= "!"; } 
				$detritus .= $SEQlist{$newname}; delete $SEQlist{$newname};
				$identity .= $QUAlist{$newname}; delete $QUAlist{$newname};
				chomp $detritus; chomp $identity;
			}
		delete $location{$newname};
		}
	}
	if ($name && length($detritus)>=1){
	print $OUT "\@$name\n$detritus\n+$name\n$identity\n"; undef $detritus, $identity, $name;
	}	
}
close $OUT;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

