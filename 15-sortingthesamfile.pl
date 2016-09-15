#!/usr/bin/perl
use strict;
# - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
#ordering a sam file
my $help = "\tORDERING A SAM FILE\nInput The name of the \"ALIGNMENT FILE\",and The name of the \"OUTPUT file\"\n\n";

# - - - - - U S E R    V A R I A B L E S  - - - - - - - - - -
my $input = $ARGV[0];
my $output = $ARGV[1];
open(OUTFILE, ">$output"); close(OUTFILE);

# - - - - - G L O B A L  V A R I A B L E S  - - - - - - - - -

my %HoA = ();

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - M A I N - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

&HOA($input); #hash table
my $start;
foreach (keys %HoA){$start .="|$HoA{$_}[0]";}
my @startposition = split('\|', $start);
my @sorted = sort {$a <=> $b} @startposition;
foreach my $name(@sorted){
    foreach my $key (keys %HoA){
        if ($HoA{$key}[0] == $name){
                
            open(OUTFILE, ">>$output");
            print OUTFILE "$key\t$HoA{$key}[0]\t$HoA{$key}[1]\n";
            close (OUTFILE);
            
            delete $HoA{$key};
        }
    }
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub HOA {
    open(INPUT,$input) or die "Cant find $input\n\n$help\n";
    while (<INPUT>){
         #my $line = $_;
        next unless m/^HW.*/;
        chomp $_;
        my @line = split(" ",$_);
        chop $line[5];
        my $result = $line[3]+$line[5]-1;
        my @arrays = ($line[3], $result);
        $HoA {$line[0]} = [ @arrays ];
    }
    print "\nCreated Hash Table\n";
    close(INPUT);
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

