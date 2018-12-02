#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@ninja.no>
#

use strict;

my $has_2 = 0;
my $has_3 = 0;

my @ids;

while (<>) {
    chomp;
    my $s = $_;
    push @ids, $s;
    
    $_ = join "", sort split //;

    $has_3++ if s/(.)\1\1//g;
    $has_2++ if s/(.)\1//g;
}

printf "Solution 1: %d * %d = %d\n", $has_2, $has_3, $has_2 * $has_3;

loop:
for my $i (0 .. @ids-2) {
    for my $j ($i+1 .. @ids-1) {
	my $ii = $ids[$i];
	my $jj = $ids[$j];
	my @c  = split //, $ii ^ $jj;
	
	my @diffs = grep { $c[$_] ne "\0" } 0..$#c;
	if (@diffs == 1) {
	    my $s = $ii;
	    substr($s, $diffs[0], 1) = '';
	    printf "Solution 2: %s\n", $s;
	    last loop;
	}
    }
}
