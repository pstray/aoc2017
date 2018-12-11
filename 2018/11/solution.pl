#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my @serials;

while (<>) {
    chomp;
    push @serials, $_;
}

$| = 1;

for my $serial (@serials) {
    my %grid;
    for my $y (1 .. 300) {
	for my $x (1 .. 300) {
	    my $id = $x + 10;
	    my $power = $id * $y + $serial;
	    $power *= $id;
	    $grid{$x}{$y} = int(($power-$power%100)/100) % 10 - 5;
	}
    }
    my $max_power = -10000; # well below 9*-5 :)
    my($max_x, $max_y);
    for my $y (1 .. 300-2) {
	for my $x (1 .. 300-2) {
	    my $power = 0;
	    for my $yy (0 .. 2) {
		for my $xx (0 .. 2) {
		    $power += $grid{$x+$xx}{$y+$yy};
		}
	    }
	    if ($power > $max_power) {
		$max_power = $power;
		$max_x = $x;
		$max_y = $y;
	    }
	}
    }

    printf "Solution 1: id=%d: level %d ad %d,%d\n", $serial, $max_power, $max_x, $max_y;

    my %pgrid;
    my $max_size = 3;
    for my $x (1 .. 300-1) {
	for my $y (1 .. 300-1) {
	    my $power = 0;
	    for my $yy (0 .. 1) {
		for my $xx (0 .. 1) {
		    $power += $grid{$x+$xx}{$y+$yy};
		}
	    }
	    $pgrid{$x}{$y} = $power;
	    if ($power > $max_power) {
		$max_power = $power;
		$max_x = $x;
		$max_y = $y;
		$max_size = 2;
	    }
	}
    }
    
    for my $size (3 .. 300) {
	printf "  %d...\r", $size;
	for my $x (1 .. 300-$size+1) {
	    for my $y (1 .. 300-$size+1) {
		my $power = $pgrid{$x}{$y};
		my $xm = $x+$size-1;
		my $ym = $y+$size-1;
		for my $zz (0 .. $size-2) {
		    $power += $grid{$xm}{$y+$zz};
		    $power += $grid{$x+$zz}{$ym};
		}
		$power += $grid{$xm}{$ym};

		$pgrid{$x}{$y} = $power;
		if ($power > $max_power) {
		    $max_power = $power;
		    $max_x = $x;
		    $max_y = $y;
		    $max_size = $size;
		}
	    }
	}
	printf "\rSolution 2: id=%d: level %d ad %d,%d,%d", $serial, $max_power, $max_x, $max_y, $max_size;
    }
    printf "\ndone\n";
    

}


