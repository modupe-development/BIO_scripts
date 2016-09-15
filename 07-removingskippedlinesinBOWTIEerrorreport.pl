#!/usr/bin/perl
# to remove all the skipped lines from the error report of bowtie
$input = $ARGV[0];
open(INPUT, "<$input") or die "Cannot find =>\t$input\n";
@details = <INPUT>;
close INPUT;

$input =~ m/^(.*)\.e.*/;
$output = "$1.xls";
open(OUTPUT,">$output");

foreach $line (@details){
	if ($line =~ m/^Warning.*/){
	}else {
		print OUTPUT $line;
	}
}
close OUTPUT;
