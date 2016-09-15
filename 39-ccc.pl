#!/usr/bin/perl
use List::Util qw( min max );
# finding the number of gaps in the sequence

open(INPUT, "<$ARGV[0]") or die "Cannot find =>\t$input\n";
$input = $ARGV[0];
$input =~ /^(.*)\..*$/;
$output = "$1-gaps.txt";
open(OUTPUT,">$output");

my $Id;
my %seq;
while (<INPUT>){
        if (/^>(.*)$/){ 
		$Id = $1;
	}
        elsif (/^(\S+)$/){ 
		$seq{$Id} .= $1 if $Id;
        }
}
print OUTPUT "SEQUENCENAME\tLENGTH\tGAPS_LENGTH\tNO_OF_GAPS\tMIN_GAP_SIZE\tMAX_GAP_SIZE\n";
foreach $seqname (keys %seq){
	$seqarray = $seq{$seqname};
	@sequencelist = split('', $seqarray);
	$sequencelistsize = $#sequencelist+1;
	$allNs=0;$Ns = 0;$gaps=0;$check=0; $finalN=''; $seqa=0;
	foreach(@sequencelist){
		$seqa++;
		if(/N/){
			$allNs++;
			$Ns++; 
			$check=1;
		}
		if(/[AGTC]/ && $check==1){
		#if($Ns==1){print "$seqa\t";}
			$finalN .="$Ns\|";
			$gaps++; 
			$Ns=0; 
			$check=0;
		}	
	}	
        @finalNs = split('\|', $finalN);
	$min = min @finalNs;
	$max = max @finalNs;

        print OUTPUT "$seqname\t$sequencelistsize\t$allNs\t$gaps\t$min\t$max\n";
}
close INPUT;
close OUTPUT;
