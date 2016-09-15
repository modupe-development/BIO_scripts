#!usr/bin/perl
use strict;
use File::Basename;
my $safe=1;
my @FILE;
my $out = fileparse($ARGV[0], qr /\.[^.]*/);
open(FILES,"<$ARGV[0]");
@FILE=<FILES>;
close FILES;

my $number=0;

foreach my $sentence(@FILE){
    if ($sentence =~/^>.*/ && $safe ==1 ){
        $number++;
        open (OUT, ">$out-$number.end"); close (OUT);
        open (OUT, ">>$out-$number.end");
        print OUT $sentence; close (OUT);
    }
    if ($sentence !~ /^>.*/) {
        open (OUT, ">>$out-$number.end");
        print OUT $sentence; close (OUT);
        $safe =1;
    }
}


