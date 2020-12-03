#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2020 by Peder Stray <peder@wintermute>
#

use strict;

my @data;

my $rows = 0;
my $columns = 0;

while (<>) {
    chomp;
    if (/^[.#]+$/) {
	$columns = length;
	push @data, [ split //, $_ ];
    }
    else {
	die "Error in data at line $.\n";
    }
}
$rows = @data;

my $solution1 = 0;

my($pos_x, $pos_y) = (0,0);
while (1) {
    $pos_x += 3;
    $pos_y += 1;
    last if $pos_y >= $rows;
    $solution1++ if $data[$pos_y][$pos_x % $columns] eq '#';
}

printf "Solution 1: %d trees\n", $solution1;

my $solution2 = $solution1;

for my $slope ([1,1],[5,1],[7,1],[1,2]) {
    my $dx = $slope->[0];
    my $dy = $slope->[1];

    my $trees = 0;
    ($pos_x, $pos_y) = (0,0);
    while (1) {
	$pos_x += $dx;
	$pos_y += $dy;
	last if $pos_y >= $rows;
	$trees++ if $data[$pos_y][$pos_x % $columns] eq '#';
    }
    $solution2 *= $trees;
}

printf "Solution 2: %d trees\n", $solution2;
