#! usr/bin/perl -w
use strict;
#OBJECTIVE
#hopefully shrink the large files into several smaller files for analysis


my $input = $ARGV[0];
my $i= 0;
unless(open(FILE,$input)){
	print "File \'$input\' doesn't exist\n";
	exit;
}


my @file = <FILE>;
chomp @file;
close (FILE);

print "The number of sequences of the file are : ", ($#file + 1)/4, "\n";
print "Saving the large file into several smaller files";


for(my $y = 0; $y < $#file; $y+=500000) {
	$i++;
	my $output = $input."-".$i.".txt";
	open (OUTPUT, ">$output");
	
	my @diff = splice(@file,$y,500000);
	print "\n$i.\t $output";
	foreach my $line (@diff){
		print OUTPUT "$line\n";
	}
	close (OUTPUT);
}
print "\n\n";
exit;
