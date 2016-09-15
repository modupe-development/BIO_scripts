#!/usr/bin/perl
use strict;
# - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
#creating a hash of arrays
my $hint = "\tNOTING MAPPING ERRORS\nInput \n\t1. The name of the \"ALIGNMENT FILE\",\n\t2. The \"COVERAGE requirement\" and, \n\t3. The name of the \"OUTPUT file\"\n\n";
# - - - - - U S E R    V A R I A B L E S  - - - - - - - - - -
my %HoAstart = ();
my %HoAend = ();
my $input = $ARGV[0];
my $output = $ARGV[2];
my $Nposition;
my ($check, $checkstart, $checkend) = (0,0,0);
my @sorted;
open(OUTFILE, ">$output"); close(OUTFILE);
# - - - - - G L O B A L  V A R I A B L E S  - - - - - - - - -
my $count = 0;
my $position1 = 0;
my $position2 = 0;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - M A I N - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
&HOA($input); #hash table for start and end positions
print "Hash table created\n";
for(my $column = 0; $column <2;$column++){
    if ($column == 0){
        @sorted = sort {$a <=> $b} values %HoAstart;
        $check = $checkstart;
        print "sorted start\t";
        open(OUTFILE, ">>$output"); print OUTFILE "\n\nTHE START POSITION\n\n"; close (OUTFILE);
    }
    if ($column == 1){
        @sorted = sort {$a <=> $b} values %HoAend;
        $check = $checkend;
        print "sorted end\t";
        open(OUTFILE, ">>$output"); print OUTFILE "\n\nTHE END POSITION\n\n"; close (OUTFILE);
    }
    my @elements = @sorted;
    my $endposition = int(((pop @elements)/10)+1)*10;
    
    for (my $bp =1; $bp < $endposition; $bp+=10){
        $Nposition = "null";
        FIRST: foreach my $value (@sorted){
                    if ($value == $bp){
                        $count++;
                        if($Nposition eq "null"){
                            $Nposition = $value;
                        }
                        shift @sorted;$check--;
                    }
                    if ($value > $bp) {
                        last FIRST;
                    }
                }
        for(my $i = 1; $i <=5; $i++){
            $position1= $bp + $i;
            SECOND: foreach my $value (@sorted){
                        if ($value == $position1){
                            $count++;
                            if($Nposition eq "null"){
                                $Nposition = $value;
                            }
                            shift @sorted;$check--;
                        }
                        if ($value > $position1) {
                            last SECOND;
                        }
                    }
        }
        for(my $j = 1; $j <=5; $j++){
            $position2= $bp - $j;
            THIRD: foreach my $value (@sorted){
                        if ($value == $position2){
                            $count++;
                            if($Nposition eq "null"){
                                $Nposition = $value;
                            }
                            shift @sorted;$check--;
                        }
                        if ($value > $position2){
                            last THIRD;
                        }
                    }
        }
        if ($count >= $ARGV[1]){
        open(OUTFILE, ">>$output"); print OUTFILE "$Nposition\t$count\n"; close (OUTFILE);
        }
    $count = 0;
    }
    print "\n";
}
print "\nUsing \n\ti. Inputfile : \'$ARGV[0]\'\n\tii. Count value of : \'$ARGV[1]\'\n";
print "=> Saved into outputfile \'$output\'\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n\n*********DONE*********\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub HOA {
    open(INPUT,$input) or die "Cant find $input\n\n$hint\n";
    while (<INPUT>){
         #my $line = $_;
        next unless m/^HW.*/;
        chomp $_;
        my @line = split(" ",$_);
        chop $line[5];
        my $result = $line[3]+$line[5]-1;
        $HoAstart{$line[0]} = $line[3];
        $HoAend{$line[0]} = $result;
        $checkstart++;
        $checkend++;
    }
close(INPUT);
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

