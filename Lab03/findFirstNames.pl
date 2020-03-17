#!/usr/bin/env perl

#NOTE: This is my first time looking at the perl programming language

# 	Program Name: findFirstNames.pl
#   Author(s): Tim Catana || Julien carpenter-fournier 
#   Earlier Contributors(s): Andrew Hamilton-Wright, Deborah Stacey
#   Project: Lab 3 script
#   Last Update: March 17, 2020.
#	Function: Takes in a CSV file and a "yob" file, compares them,
#			  and prints out the names found in both files.
#	Compilation:  chmod u+x findFirstNames.pl                              OR     none needed
#	Excecution:   ./findFirstNames <yob1990.txt> <CISNames.csv>            OR     perl findFirstNames <yob1990.txt> <CISNames.csv>  
#
#      References
#         Name files from http://www.ssa.gov/OACT/babynames/limits.html
#


# Packages and modules
use strict;
use warnings;

# This will ensure that the version of Perl to be used is at least this new
use version;   our $VERSION = qv('5.16.0');

# Here we must *forward declare* our modules, meaning that if we want
# to use them below, we need to tell perl that here.
# We will be using the CSV module (version 1.32 or higher) to parse each line
use Text::CSV  1.32;
# We will be using the BOM module (version 0.16 or higher) to get rid of
# and Byte Order Marks that we have in our input files
use File::BOM  0.16;


# Variables to be used

# These two variables are a quoted space, and a quoted comma.  Sometimes
# you will see these constructed through the 'q' operator, and sometimes
# with quoted strings.  The value q{,} is the same as ",", and q{} is
# the empty string "".  You will see that Perl::Critic will recommend
# these values, referring to page 53 of PBP, as this is more visible
# than the simple quoting, and therefore more legible.
my $SPACE = q{ };
my $COMMA = q{,};
my $EMPTY = q{};

# variables used in computations below
my $namedata_filename1 = $EMPTY;
my $namedata_filename2 = $EMPTY;

my @lines1;
my @lines2;
my $record_count1 = 0;
my $record_count2 = 0;
my $female_count = 0;
my $male_count   = 0;
my @given_name1;
my @given_name2;
my @sex;
my @number;
my $found_name = 0; #1 = found 0 = not found

my $name_cnt = 0;
my $notfound_name_cnt = 0;

# set up our CSV (Comma Separated Value) parser
my $csv = Text::CSV->new({ sep_char => $COMMA });

# Check that we have been given the right number of parameters,
# and store the single command line argument in a variable with
# a better name
if ($#ARGV != 1 ) {
    print "Usage: readNames.pl <yobfile.txt> <CISNames.csv>\n" or die "Print failure\n";
    exit;
} else {
    $namedata_filename1 = 'Names/'.$ARGV[0];
    $namedata_filename2 = $ARGV[1];
}

# Open the input file and load the contents into an array, where
# each array location holds one line from the file

# store lines from txt file
open my $names1_fh, '<:via(File::BOM)', $namedata_filename1
        or die "Unable to open names file: '$namedata_filename1'\n";
@lines1 = <$names1_fh>;
close $names1_fh or
        die "Unable to close: $ARGV[0]\n";   # Close the input file
		

# store lines from csv file
open my $names2_fh, '<:via(File::BOM)', $namedata_filename2
        or die "Unable to open names file: '$namedata_filename2'\n";
@lines2 = <$names2_fh>;
close $names2_fh or
        die "Unable to close: $ARGV[0]\n";   # Close the input file


# Parse each line of data from the array holding the file contents,
# and break the line into fields based on the comma delimiter, where
# the fields are stored in a different array for only this line of
# data.

# parse the txt file data
foreach my $name_record1 ( @lines1 ) {

    # uncomment this to see the raw line of the file

    # print $name_record;
    if ( $csv->parse($name_record1) ) {
        my @master_fields = $csv->fields();
		
        # uncomment this to see the full list of all of the parsed fields
        # print @master_fields;
        
		$given_name1[$record_count1] = $master_fields[0];
        $sex[$record_count1]        = $master_fields[1];
        $number[$record_count1]     = $master_fields[2];
        $record_count1++;
    } else {
        warn "Line/record could not be parsed: $name_record1\n";
    }
}

# parse the csv file data
foreach my $name_record2 ( @lines2 ) {
    if ( $csv->parse($name_record2) ) {
        my @master_fields = $csv->fields();
        $given_name2[$record_count2] = $master_fields[0];
        $record_count2++;
    } else {
        warn "Line/record could not be parsed: $name_record2\n";
    }
}

# compare the two files and print out the names found in both files
for my $i ( 0..($record_count2-1) ) {
  $female_count = 0;
  $male_count = 0;
  $found_name = 0;

  for my $j ( 0..($record_count1-1) ) {
    if( $sex[$j] eq 'F' ){
      $female_count++;
    }
    if($sex[$j] eq 'M'){
      $male_count++;
    }

    if ($given_name1[$j] eq $given_name2[$i] && $found_name != 1 && $sex[$j] eq 'F'){
     print $given_name2[$i].$SPACE."(".$female_count or
               die "Prinf failure\n";
      $found_name = 1;
      $name_cnt++;
    }

    if ($given_name1[$j] eq $given_name2[$i] && $found_name != 1 && $sex[$j] eq 'M'){
    print $given_name2[$i].$SPACE."(".$male_count.")"."\n" or
               die "Prinf failure\n";
      $found_name = 3;
      $name_cnt++;
    }
	
	
    if ($given_name1[$j] eq $given_name2[$i] && $found_name == 1 && $sex[$j] eq 'M'){
    print $SPACE.$male_count.")"."\n" or
               die "Prinf failure\n";
      $found_name = 2;
    }
  }

  if($found_name == 1){
    print ")"."\n" or
              die "Prinf failure\n";
  }

  if($found_name == 0){
    print $given_name2[$i].$SPACE."("."0".")"."\n" or
              die "Prinf failure\n";
    $notfound_name_cnt++;
  }
}

# print the number of names in both files and not found in both files
print "Number of found names:".$SPACE.$name_cnt."\n" or
          die "Prinf failure\n";

print "Number of missing names:".$SPACE.$notfound_name_cnt."\n" or
          die "Prinf failure\n";
# End of Script