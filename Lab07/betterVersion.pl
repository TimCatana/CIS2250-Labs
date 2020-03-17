#!/usr/bin/perl
use strict;
use warnings;

#
#  dictionaryProcessor.pl
#
#  Author: Tim Catana
#  Commandline: perl dictionaryProcessor.pl <dictionaryFileName1> <dictionaryFileName2> ...
#  Notes: - can have any number of dictionaryFileName files
#
#  Functionality
#     dictionaryProcessor.pl takes a (or multiple) file that consists of words and their
#     definitions (both on one line) and does the following:
#        a) loads an internal wordlist with cleaned up versions of the words (no punctuation, etc.)
#        b) given a word, prints out its definition
#        c) given a string of letters, finds all words that start with this substring
#


#
# Subroutines
#

# take the line and regulate to consist only of latin letters and digits
sub fixit {
   my ( $inputLine ) = @_;
   $inputLine = lc($inputLine);
   $inputLine =~ s/[\s]//g;
   return ($inputLine);
}

# count the number of tokens in an array (how many "words" a word is made up of)
sub tokenCount {
   my @words_array = split(/ /,$_[0]);
   return ($#words_array + 1);
}

# get user input
sub getInput {
   $_ = <STDIN>;
   chomp;
   return ($_);
}

#
#Variables
#

my @word_defns;
my @current_line;

my $controller = 0; # 0 = use all words, 1 = ignore multiple part words
my $word_count = 0;
my $is_flag_found = 0; # 0 = token not found (yet), 1 = found token
my $word;

#
#Begin Script
#

if( $#ARGV + 1 < 1){
	print 'Please give at least one dictionary file in the command line'."\n" or die 'failed to print'.$!;
	exit;
}

print 'Do you want to ignore multiple part words [Y or N]? : ' or die 'failed to print'.$!;
my $answer = <STDIN>;
chomp($answer);

if ( uc($answer) eq 'Y' ) {
   $controller = 1;
} else {
   $controller = 0;
}

## Assume mltiple arguments, set an array that holds "word/definition" at each index
for my $i ( 0..($#ARGV) ) {
	my $filename = $ARGV[$i];
	print 'Loading data file ' . $filename . "\n" or die 'failed to print'.$!;
	open my $fp, $filename or die "Unable to open file $filename ".$!;
	
	while ( <$fp> ) {
		chomp;
		@current_line = split(/\//); # assumes what we are splitting
		$word =  $current_line[0]; 
		
		if ( $controller == 0 || tokenCount($word) == 1 ) {
			$word = fixit($word);
			$word_defns[$word_count] =  $word . '/' . $current_line[1];
			$word_count++;
		   }
		}
	close $fp or die "failed to close $fp".$!;
}

## sort words alphabetically before we break into seperate files
my @sorted_word_defns = sort { lc($a) cmp lc($b) } @word_defns;

## break dictionary into separate files for each starting letter
my @file_letters;
my $file_count; # used to index @file_letters 
my $start_letter;
my $j = 0;

while ( $j < $word_count ) {
   $start_letter = substr($sorted_word_defns[$j],0,1);
   $file_letters[$file_count++] = $start_letter;
   my $filename = ">" . $start_letter . 'WordDefns.txt';
   open my $fp, $filename or die "Unable to open file $filename ".$!;
   
   while ( $j < $word_count && $start_letter eq substr($sorted_word_defns[$j],0,1)  ) {
      print $fp "$sorted_word_defns[$j]\n" or die 'failed to print'.$!;
      $j++;
   }
   
   close $fp or die "failed to close $fp".$!;
}


## Find the definition of a given word
my $line;
my $does_file_exist = 0; # 0 = file we are looking for doesn's exist, 1 = it does exist 

print 'Find the definition - Enter the term [or 0 to quit this search]: ' or die 'failed to print'.$!;
my $defn_find = <STDIN>;
chomp($defn_find);

while ( $defn_find ne '0' ) {
   $defn_find = fixit($defn_find);
   $start_letter = substr($defn_find,0,1); # we know what file to look in based on the starting letter
   $does_file_exist = 0;
   $is_flag_found = 0;
   
   #make sure file needed to check exists
   for my $i ( 0..($#file_letters) ) { # no '+1' to file_letter size because '$file_letters[$file_count++] = $start_letter;' expands array by 1 too many
	   if($start_letter eq $file_letters[$i]){
		 $does_file_exist = 1;
		 last;
	   }
   }
   
   print "\n" or die 'failed to print'.$!; # output beautifying purposes
   
   if($does_file_exist == 1){
	   my $filename = "<" . $start_letter . 'WordDefns.txt';
	   open my $fp, $filename or die $!;
	   
	   while ( defined ($line = <$fp>) ) {
		  chomp($line);
		  @current_line = split(/\//,$line);
		  $word = $current_line[0];
		 
		  if ( $word eq $defn_find ) {
			print "Definition: $current_line[1]\n\n" or die 'failed to print'.$!;
			$is_flag_found = 1;
		  }
	   }
	   close $fp or die "failed to close $fp".$!;
   }
   
   if ($is_flag_found == 0) {
	 print "Definition: None found\n\n" or die 'failed to print'.$!;
   }
   
   print 'Find the definition - Enter the term [or 0 to quit this search]: ' or die 'failed to print'.$!;
   $defn_find = <STDIN>;
   chomp($defn_find);
}


## Find all words that contain a given string
print 'Find all words containing the following string [or 0 to quit this search]: ' or die 'failed to print'.$!;
my $strFind;
$strFind = getInput($strFind);

while ( $strFind ne '0' ) {
   $strFind = fixit($strFind);
   print "\n" or die 'failed to print'.$!; # output beautifying purposes
   
   for my $i ( 0..($#ARGV) ) {
	   my $filename = $ARGV[$i];
	   open my $fp, $filename or die $!;
	   $is_flag_found = 0;

		while ( defined ($line = <$fp>) ) {
			chomp($line);
			@current_line = split(/\//,$line);
			$word = $current_line[0];

			# look anywhere in the string for $strFind
			my $indexFound = index( $word, $strFind );
			 
			if ( $indexFound >= 0 ) {
				print "$word\n" or die 'failed to print'.$!;
				$is_flag_found = 1;
			}
		}
	   
	   close $fp or die "failed to close $fp".$!;
	   
	   if ( $is_flag_found == 0 ) {
		  print "None found\n\n" or die 'failed to print'.$!;
	   } else {
	      print "\n" or die 'failed to print'.$!; # output beautifying purposes
	   }
	}
	   
   print 'Find all words containing the following string [or 0 to quit this search]: ' or die 'failed to print'.$!;
   $strFind = getInput($strFind);  
}
#END OF SCRIPT

