#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;
use Data::Dumper;

my $solution1;
my $solution2;

my $min_val;
my $max_val;

while (<>) {
    chomp;
    if (/^(\d+)-(\d+)$/) {
	($min_val,$max_val) = ($1,$2);
	last;
    }
    else {
	die "Kablam! $_\n";
    }
}

PASS:
for ($min_val .. $max_val) {
    next unless /(.)\1/;
    my(@dig) = split //;
    for my $i (1 .. @dig-1) {
	next PASS if $dig[$i] < $dig[$i-1];
    }
    $solution1++;
    my($neg,$pos);
    while (/((.)\2+)/g) {
	if (length($1) > 2) {
	    $neg++;
	}
	else {
	    $pos++;
	}
    }
    next if $neg && !$pos;
    $solution2++;
}
printf "Solution 1: %s\n", $solution1;
printf "Solution 2: %s\n", $solution2;
