#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my $valid_passwords1 = 0;
while (<>) {
    chomp;
    my(%words1);
    my $valid1 = 1;
    for my $word (split " ") {
	$valid1 = 0 if ++$words1{$word} > 1;
    }
    $valid_passwords1++ if $valid1;
}

printf "Solution 1: %d\n", $valid_passwords1;
