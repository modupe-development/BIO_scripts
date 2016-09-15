#!/usr/bin/perl
use strict;
#creating txt sheets for each chromosome of Rnor5



# - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
# - - - - - U S E R    V A R I A B L E S  - - - - - - - - - -
# - - - - - G L O B A L  V A R I A B L E S  - - - - - - - - -
my %nameoffile;
my $headers;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - M A I N - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
<>;
while(<>) {
    chomp;
    my $start;
    my $end;
    my @line=split(/\t/,$_);
    if (exists $nameoffile{$line[0]}){
        open(OUT, ">>$line[0]");
        print OUT "$_\n";
        close (OUT);
    }
    else {
        $nameoffile{$line[0]} = 1;
        open (OUTHEADER, ">$line[0]"); print OUTHEADER "$_\n"; close (OUTHEADER);
    }
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

