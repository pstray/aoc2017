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

my $half = @input/2;
my $half_sum = 0;
for my $pos (0..$half) {
    if ($input[$pos] == $input[$pos+$half]) {
	$half_sum += $input[$pos];
    }
}
$half_sum *= 2; # since the list is circular

printf "Solution 1: %d\n", $sum;
printf "Solution 2: %d\n", $half_sum;
