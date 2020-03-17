#!/usr/bin/env perl

# 	Program Name: firstNamesByTime.pl
#   Author(s): Tim Catana || Shayan Mohammed
#   Earlier Contributors(s): Andrew Hamilton-Wright, Deborah Stacey
#   Project: Lab 4 script
#   Last Update: March 17, 2020.
#	Function: Takes in the names and gender from queryNames.txt and
#			  looks for these names in a list of given years
#	Notes: 
#	Compilation:  chmod u+x firstNamesByTime.pl                                                    OR        none needed
#	Excecution:  ./firstNamesByTime <start year> <end year> <year increment> queryNames.txt        OR        perl firstNamesByTime <start year> <end year> <year increment> queryNames.txt
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

my $namedata_filename1 = $EMPTY;
my $namedata_filename2 = $EMPTY;

my @lines1;
my $record_count1 = 0;
my $record_count2 = 0;
my @given_name1;
my @given_name2;
my @sex1;
my @sex2;
my $female_rank = 0;
my $male_rank = 0;
my $loop_count = 0;
my $start_year = 0;
my $query_index_check = 0;
my $query_file = 0;
my $year_increment = 0;
my $current_file = 0;

my $csv = Text::CSV->new({ sep_char => $COMMA });

if ($#ARGV != 3 ) {
    print "Usage: ./firstNamesByTime <start year> <end year> <year increment> queryNames.txt  \n"
        or die "Print failure\n";
    exit;
} else {
    $namedata_filename1 = $ARGV[0];
    $namedata_filename2 = $ARGV[1];
    $year_increment = $ARGV[2];
    $query_file = $ARGV[3]
}

if($namedata_filename1 > $namedata_filename2){
	print "ERROR - start year must be less than end year\n"
        or die "Print failure\n";
	exit;
}

# Used below to monitor the while loop
$start_year = $namedata_filename1;

open my $query_names, '<:via(File::BOM)', $query_file
        or die "Unable to open names file: '$query_file'\n";
@lines1 = <$query_names>;
close $query_names or
        die "Unable to close: $ARGV[3]\n"; 


foreach my $name_record1 ( @lines1 ) {

    if ( $csv->parse($name_record1) ) {
        my @master_fields = $csv->fields();
        $given_name1[$record_count1] = $master_fields[0];
        $sex1[$record_count1]        = $master_fields[1];
        $record_count1++;
    } else {
        warn "Line/record could not be parsed: $name_record1\n";
    }

}

# Print header at the top of the output
print "Name,Year,Ranking\n"
    or die "Print failure\n";
		
while($namedata_filename1 <= $namedata_filename2){
  $record_count2 = 0;
  $current_file = join $namedata_filename1,'Names/yob','.txt'; # concatonate year to make a file name

  open my $names1_fh, '<:via(File::BOM)', $current_file
           or die "Unable to open names file: '$current_file'";
  my @lines2 = <$names1_fh>;
  close $names1_fh or
        die "Unable to close: $ARGV[0]\n"; 
		
  foreach my $name_record2 ( @lines2 ) {

      if ( $csv->parse($name_record2) ) {
          my @master_fields = $csv->fields();
          $given_name2[$record_count2] = $master_fields[0];
          $sex2[$record_count2] = $master_fields[1];
          $record_count2++;
      } else {
          warn "Line/record could not be parsed: $name_record2\n";
      }
	  
  }

  $female_rank = 0;
  $male_rank = 0;

  for my $i ( 0..($record_count2-1) ) {
      if($sex2[$i] eq 'F'){
        $female_rank++;
      }
      if($sex2[$i] eq 'M'){
        $male_rank++;
      }

      if($given_name1[$query_index_check] eq $given_name2[$i] && $sex1[$query_index_check] eq $sex2[$i] ){

        if($sex2[$i] eq 'F'){
            print $given_name2[$i].",".$namedata_filename1.",".$female_rank."\n" or
                  die "Print failure\n";
        }		
        if($sex2[$i] eq 'M'){
            print $given_name2[$i].",".$namedata_filename1.",".$male_rank."\n" or
                  die "Print failure\n";
        }
		
      }
  }

  $namedata_filename1 += $year_increment;

  if($namedata_filename1 > $namedata_filename2 && $loop_count != ($record_count1 -1) ){
		$loop_count++;
		$query_index_check++;
		$namedata_filename1 = $start_year;
  }
}
# End of Script