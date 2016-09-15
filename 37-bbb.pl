#!/usr/bin/perl
# convert fasta file to a table file

open(INPUT, "<$ARGV[0]") or die "Cannot find =>\t$input\n";
$input = $ARGV[0];
$input =~ /^(.*)\..*$/;
$output = "$1-tableoffasta.txt";
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
foreach (keys %seq){
	print OUTPUT "$_\t$seq{$_}\n";
}
close INPUT;
close OUTPUT;
