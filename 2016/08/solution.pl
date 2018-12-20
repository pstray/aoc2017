#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

my @screen = map { [('.')x50] } 0..5;

while (<>) {
    chomp;
    if (my($xx,$yy) = /^rect\s+(\d+)x(\d+)$/) {
	for my $y (0 .. $yy-1) {
	    for my $x (0 .. $xx-1) {
		$screen[$y][$x] = '#';
	    }
	}
    }
    elsif (my($rr,$nn) = /^rotate row y=(\d+) by (\d+)$/) {
	splice @{$screen[$rr]}, 0, 0, splice @{$screen[$rr]}, -$nn, $nn;
    }
    elsif (my($cc,$nn) = /^rotate column x=(\d+) by (\d+)$/) {
	my @c = map { $screen[$_][$cc] } 0 .. @screen-1;
	splice @c, 0, 0, splice @c, -$nn, $nn;
	for my $r (0 .. @screen-1) {
	    $screen[$r][$cc] = $c[$r];
	}
    }
    else {
	die "Unknown input: [$_]\n";
    }
}

printf "Solution 2:\n";
my $sum = 0;
for my $row (@screen) {
    $sum += grep {$_ eq '#'} @$row;
    printf "%s\n", join "", @$row;
}
print "\n";
printf "Solution 1: %d lit pixels\n", $sum;
