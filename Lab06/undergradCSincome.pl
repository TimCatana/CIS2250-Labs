#!/usr/bin/env perl

#
# 	Program Name: undergradCSincome.pl
#   Author(s): Tim Catana | Gabriel Pasqualoni | Luka Vukadinovic | Mohammad Kanth 
#   Earlier contributors(s): Andrew Hamilton-Wright, Deborah Stacey, Carson Mifsud
#   Project: Lab 6 Script
#   Last Update: March 17, 2020.
#   Function: takes in a CSV (comma separated version) file and prints out year, 
#			  years after graduation, and the total income of that year for 
#			  rows that contain undergraduate degree, total gender, age groups 15 - 64
#	Compilation:   chmod u+x undergradCSincome.pl                      OR      none needed
#	Excecution:   ./undergradCSincome.pl <educationON.csv>             OR      perl  undergradCSincome.pl <educationON.csv>  
#


# Packages and modules
use strict;
use warnings;
use version;   our $VERSION = qv('5.16.0');
use Text::CSV  1.32;
use File::BOM  0.16;

# Variables 
my $SPACE = q{ };
my $COMMA = q{,};
my $EMPTY = q{};

my @lines;
my $file;
my @year = @_;
my @YAGrad= @_;
my @income= @_;
my @degree= @_;
my @ageGroup = @_;
my @gender = @_;
my $index = 0;
my $csv = Text::CSV->new({ sep_char => $COMMA });

if ($#ARGV != 0 ) {
    print "Usage: undergradCSincome.pl <educationON.csv>\n" or die "Print failure\n";
    exit;
} else {
    $file = $ARGV[0];
}

open my $names1_fh, '<:via(File::BOM)', $file
        or die "Unable to open names file: '$file'\n";
@lines = <$names1_fh>;
close $names1_fh or
        die "Unable to close: $ARGV[0]\n";   # Close the input file

foreach my $name_record1 ( @lines ) {

    if ( $csv->parse($name_record1) ) {
        my @master_fields = $csv->fields();
        $year[$index] = $master_fields[0];
        $degree[$index] = $master_fields[3];
        $gender[$index] = $master_fields[5];
        $ageGroup[$index] = $master_fields[6];
        $YAGrad[$index] = $master_fields[9];
        $income[$index] = $master_fields[16];
        $index++;
    } else {
        warn "Line/record could not be parsed: $name_record1\n";
	}

}

print "Year,YearsAfterGraduation,Dollars"."\n";

foreach my $i (0 .. ($index - 1) ) {
    if($degree[$i] eq "Undergraduate degree" && $gender[$i] eq "Total, gender" && $ageGroup[$i] eq "15 to 64 years"){
		print $year[$i].","."\"$YAGrad[$i]\"".",".$income[$i]."\n";
    }
}
# End of Script