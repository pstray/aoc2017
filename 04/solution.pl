#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my $valid_passwords1 = 0;
my $valid_passwords2 = 0;

while (<>) {
    chomp;
    my(%words1,%words2);
    my $valid1 = 1;
    my $valid2 = 1;
    for my $word (split " ") {
	$valid1 = 0 if ++$words1{$word} > 1;
	$valid2 = 0 if ++$words2{join "", sort split "", $word} > 1;
    }
    $valid_passwords1++ if $valid1;
    $valid_passwords2++ if $valid1 && $valid2;
}

printf "Solution 1: %d\n", $valid_passwords1;
printf "Solution 2: %d\n", $valid_passwords2;
