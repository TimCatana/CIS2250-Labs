#!/usr/bin/env perl

#
# convertRankingToRankCategory.pl
#   Author(s): Andrew Hamilton-Wright, Kassy Raymond
#
#   Project: Lab Assignment 4 Script
#   Date of Last Update: Dec 16, 2019.
#
#   Functional Summary
#       convertRankingToRankCategory.pl reads a CSV file that is
#       assumed to have a column called "Ranking".  The values in
#       this column are converted to rank categories that are
#       printed to the screen, using the following scheme:
#
#           Rank Range      Rank Category Number
#               0               0
#           > 2000              1
#           1000 - 2000         2
#            500 - 999          3
#            200 - 499          4
#            100 - 199          5
#             50 - 99           6
#             11 - 49           7
#              1 - 10           8
#
#      Commandline Parameters:2 
#         $ARGV[0] = name of file to convert
#


#
#   Packages and modules
#
use strict;
use warnings;

# This will ensure that the version of Perl to be used is at least this new
use version;   our $VERSION = qv('5.16.0');

# Here we must *forward declare* our modules, meaning that if we want
# to use them below, we need to tell perl that here.
#
# We will be using the CSV module (version 1.32 or higher) to parse each line
use Text::CSV  1.32;
# We will be using the BOM module (version 0.16 or higher) to get rid of
# and Byte Order Marks that we have in our input files
use File::BOM  0.16;



# Set up our delimiter string
my $COMMA = ",";


#
#   Functions for use below
#
sub printLine {
    # give a better name to the list of fields
    my @field_list = @_;

    # print the first value (with no newline)
    print $field_list[0];

    foreach my $i ( 1 .. $#field_list ) {
        print $COMMA.$field_list[$i];
    }
    print "\n";
}

#
#   Variables to be used
#

# variables used in computations below

my $rank_column = -1;
my $line;


# set up our CSV (Comma Separated Value) parser
my $csv          = Text::CSV->new({ sep_char => $COMMA });


#
#   Check that we have been given the right number of parameters,
#   and store the single command line argument in a variable with
#   a better name
#
if ($#ARGV != 0 ) {
    print "Usage: convertRankingToRankCategory.pl <ranking file>\n" or die "Print failure\n";
    exit;
}
my $ranking_filename = $ARGV[0];


#
# Open the data file
#
open my $ranking_fh, '<:via(File::BOM)', $ranking_filename
        or die "Unable to open data file: '$ranking_filename'\n";

# read in the first (header) line and find the ranking column
$line = <$ranking_fh>;
$csv->parse($line) or die "Cannot parse fields from first line:".$line."\n";
my @header_fields = $csv->fields();

# use the length of the array of fields found to know how far to search
$rank_column = -1;
foreach my $i (0 .. $#header_fields) {

    # get only the first four characters from the field name
    my $fieldname_leader = substr $header_fields[$i], 0, 4;

    if ( $fieldname_leader eq "rank" or $fieldname_leader eq "Rank" ) {
        $rank_column = $i
    }
}

# check that we found something
$rank_column >= 0 or die "No 'rank' column in data file\n";

# Now convert the name and print
$header_fields[ $rank_column ] = "RankCategory";
printLine( @header_fields );



#
# We have found the field to convert and handled the header,
# so now we simply process the rest of the file, converting
# the value in our Ranking column as we go
#

# while loop will process all the remaining lines
my $line_no = 1;
while ( $line = <$ranking_fh> ) {

    $line_no++;
    $csv->parse($line) or
            die "Cannot parse fields from line $line_no:".$line."\n";
    my @data_fields = $csv->fields();

    my $rank_value = $data_fields[ $rank_column ];
    my $category_value = -1;

    if ( $rank_value == 0 ) {
        # keep the value the same
        $category_value = 0;

    } elsif ( $rank_value > 2000 ) {
        $category_value = 1;

        # we only check relative to 1000, as anything above 2000
        # has already been handled.  Note also that we switch to
        # greater than or equal to
    } elsif ( $rank_value >= 1000 ) {
        $category_value = 2;

    } elsif ( $rank_value >= 500 ) {
        $category_value = 3;

    } elsif ( $rank_value >= 200 ) {
        $category_value = 4;

    } elsif ( $rank_value >= 100 ) {
        $category_value = 5;

    } elsif ( $rank_value >= 50 ) {
        $category_value = 6;

    } elsif ( $rank_value >= 11 ) {
        $category_value = 7;

    } else {
        $category_value = 8;
    }

    # Substitute the converted value and print
    $data_fields[ $rank_column ] = $category_value;
    printLine( @data_fields )
}

# close the input file because we are done
close $ranking_fh or die "Unable to close: $ranking_filename\n";

#
#   End of Script
#
