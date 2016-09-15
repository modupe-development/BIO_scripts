#!/usr/bin/perl
# to save the important columns in the SNPs output ".bed" file from blasrTobedoutput

$input = $ARGV[0];
open(INPUT, "<$input") or die "Cannot find =>\t$input\n";
$input =~ m/^(.*)\.bed$/;
$output = "$1_new.bed";
open(OUTPUT,">$output");

while (<INPUT>){
	@lines = split("\t", $_);
	print OUTPUT "$lines[0]\t$lines[1]\t$lines[2]\t$lines[3]\t0\t$lines[5]\t$lines[6]\t$lines[7]\n";
}
close INPUT;
close OUTPUT;
