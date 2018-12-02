#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@ninja.no>
#

use strict;

my $freq = 0;
my @freqs;

my %freqs_seen;
my $cal_freq;

while (<>) {
    chomp;
    push @freqs, $_;
    $freq += $_;
    $cal_freq //= $freq if ++$freqs_seen{"$freq"} > 1;
}

printf "Solution 1: %d (from %d elements)\n", $freq, 0+@freqs;

my $loop = 0;
unless (defined $cal_freq) {
  loop:
    while (1) {
	$loop++;
	for my $f (@freqs) {
	    $freq += $f;
	    if (++$freqs_seen{"$freq"} > 1) {
		$cal_freq = $freq;
		last loop;
	    }
	}
    }
}

printf "Solution 2: %d after loop %d\n", $cal_freq, $loop;
