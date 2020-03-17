#!/usr/bin/perl
use strict;
use warnings;

#
#  dictionaryProcess.pl
#
#  Author: superHaxor
#  Commandline: perl dictionaryProcess.pl <dictionaryFileName>
#
#  Functionality
#     newProcessit.pl takes a file that consists of words and their
#     definitions (both on one line) and does the following:
#        a) loads an internal wordlist with cleaned up versions of the words (no punctuation, etc.)
#        b) given a word, prints out its definition
#        c) given a string of letters, finds all words that start with this substring
#        d) given a first letter, minimum and maximum number of letters and a number of
#           words finds a random selection of the given number of words that start with
#           the given letter and are between the minimum and maximum lengths given
#



#
# Subroutines
#

sub fixit {
   my ( $inputLine ) = @_;
   $inputLine =~ s/[^a-z0-9]//g;
   return ($inputLine);
}

sub toLowerCase {
   my ( $inputLine ) = @_;
   $inputLine =~ s/[a-z]/[A-Z]/g;
   return ($inputLine);
}

sub tokenCount {
   my @word_array = split(/ /,$_[0]);
   return ($#word_array + 1);
}

# get the first token
sub getFirst {
  return $_[0];
}


my @wordDefns;
my $controller = 0;
my $total = 0;
my $flag = 0;


print "Do you want to ignore multiple part words [Y or N]? : ";
my $answer = <STDIN>;
chomp($answer);
if ( $answer eq "Y" ) {
   $controller = 0;
} else {
   $controller = 1;
}

for my $i ( 0..($#ARGV) ) {
    my $infilename = $ARGV[$i];
    print "Loading data file " . $infilename . "\n";
    open INFILE, $infilename or die $!;

    my @val_array;
    my $word;
    while ( <INFILE> ) {
       chomp;
       @val_array = split(/\//,$_);
       $word =  lc($val_array[0]);  # lower case
       if ( $controller == 1 || tokenCount($word) == 1 ) {
          fixit($word);
          $wordDefns[$total] =  $word . "/" . $val_array[1];
          $total++;
       } 
    }
    close INFILE;
}

my @sortedWordDefns = sort { lc($a) cmp lc($b) } @wordDefns;   # alphabetical sort


## break dictionary into separate files for each starting letter
my $i = 0;
my $filename;
my $letter;
while ( $i < $total ) {
   $letter = substr($sortedWordDefns[$i],0,1);
   $filename = ">" . $letter . "WordDefns.txt";
   open FILE, $filename or die $!;
   while ( $i < $total && ($letter eq substr($sortedWordDefns[$i],0,1)) ) {
      print FILE "$sortedWordDefns[$i]\n";
      $i++;
   }
   close FILE;
}

print "Find the definition - Enter the term [or 0 to quit this search]: ";
my $defnFind = <STDIN>;
chomp($defnFind);

my $line;
while ( $defnFind ne "0" ) {
   $defnFind = lc($defnFind);
   fixit($defnFind);

   ## we know what file to look in based on the starting letter
   $letter = substr($defnFind,0,1);
   $filename = "<" . $letter . "WordDefns.txt";
   open FILE, $filename or die $!;
   $flag = 0;
   while ( $flag == 0 ) {
      if ( defined ($line = <FILE>) ) {
         chomp($line);
         my @val_array = split(/\//,$line);
         my $word = getFirst( @val_array );
         if ( $word eq $defnFind ) {
            print "Definition: $val_array[1]\n";
            $flag = 1;
         }
      } else {
         $flag = 2;
      }
   }

   if ( $flag == 2 ) {
      print "Definition: None found\n";
   }
   print "Find the definition - Enter the term [or 0 to quit this search]: ";
   $defnFind = <STDIN>;
   chomp($defnFind);
}

print "Find all words containing the following string [or 0 to quit this search]: ";
my $strFind = <STDIN>;
chomp($strFind);
while ( $strFind ne "0" ) {
   $strFind = lc($strFind);
   $strFind = fixit($strFind);

   $letter = substr($strFind,0,1);
   $filename = "<" . $letter . "WordDefns.txt";
   open FILE, $filename or die $!;
   $flag = 0;
   while ( $flag < 1 ) {
      if ( defined ($line = <FILE>) ) {
         chomp($line);
         my @val_array = split(/\//,$line);
         my $word = $val_array[0];


         # look anywhere in the string for $strFind
         my $indexFound = index( $word, $strFind );
         if ( $indexFound >= 0 ) {
            print "$word\n";
            $flag = 1;
         }
         #print "word '" . $word . "' index " . $indexFound . "\n";
    
      } else {
         $flag = 2;
      }
   }
   close FILE;
   if ( $flag == 2 ) {
      print "None found\n";
   }
   print "Find all words containing the following string [or 0 to quit this search]: ";
   $strFind = <STDIN>;
   chomp($strFind);
}

