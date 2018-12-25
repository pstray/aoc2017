#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;
$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

use Getopt::Long;

my $part = 1;
GetOptions('1|part1' => sub { $part = 1 },
	   '2|part2' => sub { $part = 2 },
	  );

my @points;
while (<>) {
    chomp;
    if (/^\s*([0-9-]+)\s*,\s*([0-9-]+)\s*,\s*([0-9-]+)\s*,\s*([0-9-]+)\s*$/) {
	push @points, [ $1, $2, $3, $4 ];
    }
    else {
	die "Unparsable input:$.: $_\n";
    }
}

my @constellations;

push @constellations, [ shift @points ];

loop:
while (@points) {
    my $added = 0;
    my $ci = @constellations-1;
    my $c = $constellations[$ci];
    # printf "C%2d\n", $ci;
  point:
    for my $pi (0 .. @points-1) {
	my $pp = $points[$pi];
	for my $cpi (0 .. @$c-1) {
	    my $cp = $c->[$cpi];
	    my $dist =
	      abs($pp->[0] - $cp->[0]) +
	      abs($pp->[1] - $cp->[1]) +
	      abs($pp->[2] - $cp->[2]) +
	      abs($pp->[3] - $cp->[3]);
	    printf("[ %3d, %3d, %3d, %3d ]--[ %3d, %3d, %3d, %3d ] = %4d\n",
		   @$pp, @$cp, $dist,
		  ) if 0;
	    if ($dist <= 3) {
		$added++;
		# printf "  adding to %d...\n", $ci+1;
		push @$c, $pp;
		$points[$pi] = undef;
		next point;
	    }
	}
    }
    @points = grep { $_ } @points;
    unless ($added) {
	push @constellations, [ shift @points ];
    }
}

my $ans1 = @constellations;

if (0) {
    for my $ci (0..@constellations-1) {
	printf "Const %d\n", $ci+1;
	for my $p (@{$constellations[$ci]}) {
	    printf "  [ %d, %d, %d, %d ]\n", @$p;
	}
    }
}

printf "Solution 1: Input creates %d constellations\n", $ans1;
