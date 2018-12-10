#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my @data;

while (<>) {
    chomp;
    if (/position=<\s*(?<x>-?\d+),\s*(?<y>-?\d+)>\s*velocity=<\s*(?<vx>-?\d+),\s*(?<vy>-?\d+)>/) {
	push @data, {%+};
    }
    else {
	print STDERR "Unparsable line: $_\n",
    }
}

printf STDERR "No input...\n" unless @data;

my $time = 0;
my($diff_x,$diff_y) = (1000000,1000000);
while (1) {
    my($min_x,$max_x,$min_y,$max_y) = (1000000,-1000000,1000000,-1000000);
    for my $d (@data) {
	$min_x = $d->{x} if $min_x > $d->{x};
	$min_y = $d->{y} if $min_y > $d->{y};
	$max_x = $d->{x} if $max_x < $d->{x};
	$max_y = $d->{y} if $max_y < $d->{y};
    }
    my $dx = $max_x - $min_x;
    my $dy = $max_y - $min_y;
    # printf("%d = %d %d %d %d - %d %d\n",
    # 	   $time,
    # 	   $min_x, $max_x, $min_y, $max_y,
    # 	   $dx, $dy
    # 	  );

    # are things spreading again?
    if ($dx > $diff_x || $dy > $diff_y) {
	# roll back to previous second...
	for my $d (@data) {
	    $d->{x} -= $d->{vx};
	    $d->{y} -= $d->{vy};
	}
	$time--;
	last;
    }
    
    $diff_x = $dx;
    $diff_y = $dy;

    $time++;
    for my $d (@data) {
	$d->{x} += $d->{vx};
	$d->{y} += $d->{vy};
    }
}

my($min_x,$max_x,$min_y,$max_y) = (1000000,-1000000,1000000,-1000000);
my $output;
for my $d (@data) {
    $output->{$d->{y}}{$d->{x}} = "#";
    $min_x = $d->{x} if $min_x > $d->{x};
    $min_y = $d->{y} if $min_y > $d->{y};
    $max_x = $d->{x} if $max_x < $d->{x};
    $max_y = $d->{y} if $max_y < $d->{y};
}
printf "Solution 1:\n";
for my $y ($min_y-1 .. $max_y+1) {
    for my $x ($min_x-1 .. $max_x+1) {
	printf "%s", $output->{$y}{$x} || " ";
    }
    printf "\n";
}

printf "Solution 2: appeared at time %d\n", $time;
