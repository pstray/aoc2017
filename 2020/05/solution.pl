#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2020 by Peder Stray <peder@wintermute>
#

use strict;

my $solution1 = 0;
my $solution2 = 0;

my @data;

while (<>) {
    if (my($row,$col) = /^([FB]{7})([LR]{3})$/) {
	$row =~ tr/BF/10/;
	$col =~ tr/RL/10/;
	my $seat = oct("0b$row$col");
	#$row = oct("0b$row");
	#$col = oct("0b$col");

	$solution1 = $seat if $seat > $solution1;

	push @data, $seat;
    }
}

@data = sort {$a <=> $b} @data;
my $next = 1+shift @data;
while ($next == $data[0]) {
    $next = 1+shift @data;
}

if ($next+1 == $data[0]) {
    $solution2 = $next;
}

printf "Solution1: %d\n", $solution1;
printf "Solution2: %d\n", $solution2;
