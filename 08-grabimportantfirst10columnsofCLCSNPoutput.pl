#!/usr/bin/perl
# to save the important columns in the SNPs output ".txt" file from CLC

$input = $ARGV[0];
open(INPUT, "<$input") or die "Cannot find =>\t$input\n";
@details = <INPUT>;
close INPUT;

$input =~ m/^(.*)\.txt/;
$output = "Relevant-$1.xls";
open(OUTPUT,">$output");

#if you don't want the header : 
shift(@details);

foreach $line (@details){
	@lines = split("\t", $line);
	for($i=0; $i<10; $i++){
		print OUTPUT $lines[$i],"\t";
	}
	print OUTPUT "\n";
}
close OUTPUT;
