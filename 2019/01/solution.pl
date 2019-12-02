#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;

my $total = 0;
my $total_add;

while (<>) {
    if (my($fuel) = /^(\d+)$/) {
	my $add = int($fuel/3)-2;
	next unless $add;
	$total += $add;
	while (1) {
	    $add = int($add/3)-2;
	    last unless $add > 0;
	    $total_add += $add;
	}
    }
}

printf "Solution 1: %d total fuel\n", $total;
printf "Solution 2: %d total fuel\n", $total + $total_add;
