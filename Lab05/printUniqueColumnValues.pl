#!/usr/bin/env perl

#
# 	Program Name: printUniqueColumnValues.pl
#   Author(s): Tim Catana | Carson Mifsud
#   Earlier contributors(s): Andrew Hamilton-Wright, Deborah Stacey
#   Project: Lab 5 Script
#   Last Update: March 17, 2020.
#	Function: takes in a CSV (comma separated version) file and a number, 
#	          and prints out unique values the column of the given umber.
#	Compilation:   chmod u+x printUniqueColumnValues.pl                          OR     none needed
#	Excecution:   ./printUniqueColumnValues.pl <file.csv> <column number>        OR     perl printUniqueColumnValues.pl <file.csv> <column number> 
#


# Packages and modules
use strict;
use warnings;
use version;   our $VERSION = qv('5.16.0');
use Text::CSV  1.32;
use File::BOM  0.16;

# Variables to be used
my $SPACE = q{ };
my $COMMA = q{,};
my $EMPTY = q{};

my @lines;
my $file;
my $columnToEdit;
my @values = @_;
my @uniqueValues = @_;
my $index = 0;
my $foundSameValue = 0; #0 = not found, 1 = found
my $csv = Text::CSV->new({ sep_char => $COMMA });

if ($#ARGV != 1 ) {
    print "Usage: printUniqueColumnValues.pl <file.csv> <column number>\n" or die "Print failure\n";
    exit;
} else {
    $file = $ARGV[0];
    $columnToEdit = $ARGV[1] ;
}

open my $names1_fh, '<:via(File::BOM)', $file
        or die "Unable to open names file: '$file'\n";
@lines = <$names1_fh>;
close $names1_fh or
        die "Unable to close: $ARGV[0]\n";   # Close the input file

foreach my $name_record1 ( @lines ) {
    if ( $csv->parse($name_record1) ) {
        my @master_fields = $csv->fields();
        $values[$index] = $master_fields[$columnToEdit];
        $index++;
    } else {
        warn "Line/record could not be parsed: $name_record1\n";
    }
}

if ($#values >= 0) {
  foreach my $i (0 .. $#values) {
  
    $foundSameValue = 1;
    foreach my $j (0 .. ($#uniqueValues) ) {
        if ($values[$i] eq $uniqueValues[$j]){
          $foundSameValue = 0;
          last;
        }
	}

    if($foundSameValue == 1){
        push(@uniqueValues, $values[$i]);
    }
	
  }
}

foreach my $i (0 .. ($#uniqueValues) ) {
    print $uniqueValues[$i]."\n";
}
# End of Script