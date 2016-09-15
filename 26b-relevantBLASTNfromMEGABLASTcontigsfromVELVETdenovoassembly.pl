use strict;
# to extract the relevant contig (gotten from BLAST) from the FRHIT denovo file
# 10/18/2012
#
# - - - - - H E A D E R - - - - - - - - - - - - - - - - - - -
$a = "\t**SELECTING THE RELEVANT CONTIGS OF THE VELVET OUTPUT**\n\n";
$b = "Type in the name of the \" VELVET Contig file \" FIRST then the \"Blast Text File\"\n\n";

# - - - - - U S E R    V A R I A B L E S  - - - - - - - - - -
#BLAST FILE
my $inputBLAST = $ARGV[1];
open (BLASTFILE, "<$ARGV[1]") or die "Cannot find file $inputBLAST\n$a$b\n";
my @blastfile = <BLASTFILE>;
close BLASTFILE;

# the output file
my $output = $ARGV[0].$ARGV[1].".blast.fa";
open (OUTPUTFILE, ">$output");

# - - - - - G L O B A L  V A R I A B L E S  - - - - - - - - -
my %VELVEThash = '';
&VELVEThashtable;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - M A I N - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
my $count = 0;
my $contiging = '';
for (my $number = 0; $number <= $#blastfile; $number++){
    if ($blastfile[$number] =~ m/^Query.*/){
        $blastfile[$number] =~ m/Query= (NODE.*)$/;
	$contiging = $1;
    }
    if ($blastfile[$number] =~ m/^Sequences producing .*/){
	    print OUTPUTFILE ">$VELVEThash{$contiging}[0]\n$VELVEThash{$contiging}[1]\n";
            $count++;
    }
}
print "Successfully saved in the outputfile $output and with a total of $count contigs\n";
close OUTPUTFILE;

print "\n\n*****************DONE*****************\n\n";
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - S U B R O U T I N E S - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub VELVEThashtable{
    $/ = ">";
    open (VELVETFILE, "<$ARGV[0]") or die "$a$b Cannot find file $ARGV[0]\n";
    while (<VELVETFILE>){
        my $line = $_;
	my @eachrealline = split(/\n/, $line);
	my $defaultcontigname = shift @eachrealline;
	my $saveddefaultcontigname = $defaultcontigname;
	$defaultcontigname =~ m/^(NODE.*):/;
	my $contigname = $1;
	pop @eachrealline;
	my $contigsequence = join('', @eachrealline);
	my @contigdetailsarray  = ($saveddefaultcontigname, $contigsequence);
	$VELVEThash{$contigname} = [ @contigdetailsarray ];
    }
    print "\nCreated Hash Table\n\n";
    close VELVETFILE;
    $/ = "\n";
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -

