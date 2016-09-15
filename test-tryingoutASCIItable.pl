#!usr/bin/perl
use strict;
#a test run
#importing ascii into the hash dictionary
my %ASCII ='';
my $filename = 'asciidata.ascii';
unless (open (ASCII, $filename)){
    print "File $filename doesn't exist";
    exit;
}

my @ascii = <ASCII>;
chomp @ascii;
close ASCII;

foreach my $line (@ascii){
    chomp $line;
    my @lines = split( " ", $line);
    #$line =~ m/(\S+)\s?/;
    my $key = $lines[1];
    #print $key;
    my $values = $lines[0];
    $ASCII{$key} = $values;
}
for my $i (keys %ASCII){
    print "$i  =  $ASCII{$i}\n";
}

my @keys = values %ASCII;
print sort {$a <=> $b} @keys;
