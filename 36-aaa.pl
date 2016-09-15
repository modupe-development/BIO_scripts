#!/usr/bin/perl
# get the 6th column and quantify

open(INPUT, "<$ARGV[0]") or die "Cannot find =>\t$input\n";
$output = "sixth_column.txt";
open(OUTPUT,">$output");
my $i = 0;
my $scaffold; my $initialscaffold;
my $scaffold_array;
while (<INPUT>){
        $i++;
        chomp $_;
	@lines = split("\t", $_);
	$scaffold = $lines[0];
	if ($scaffold !~ m/^\#/){
		if ($scaffold eq $initialscaffold){
			$scaffold_array .= "|$lines[5]"; 
		}
		else {
		    if ($initialscaffold) {
			     print OUTPUT "$initialscaffold\t:\t%$scaffold_array%\n"; # the "%" is just for statistics, it needs to be removed if further analysis is needed.
		    }
			$initialscaffold = $scaffold;
			$scaffold_array = $lines[5];
		}
	}
}
print "lines = $i\n";
close INPUT;
close OUTPUT;
