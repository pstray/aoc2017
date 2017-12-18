#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my $input = do { local $/ = undef; <> };
$input =~ y/0-9//cd; # just to make sure we _only_ have digits

my(@input) = split //, $input;
my $prev = shift @input;

# Add first char to end of list to get the circularity
push @input, $prev;

my $sum = 0;

for my $digit (@input) {
    if ($prev == $digit) {
	$sum += $digit;
    }
    $prev = $digit;
}

printf "Solution 1: %d\n", $sum;
