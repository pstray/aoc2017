#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my @input;
while (<>) {
    chomp;
    push @input, split /,\s*/;
}

my $heading = 0;
my @headings = ([0,1],[1,0],[0,-1],[-1,0]);

my $x = 0;
my $y = 0;
my %seen;

$seen{$x,$y}++;
my $seen = 0;

my($x2,$y2);

for my $step (@input) {
    my($dist);
    if ($step =~ /^R(\d+)/) {
	$dist = $1;
	$heading = ($heading+1) % @headings;
    }
    elsif ($step =~ /^L(\d+)/) {
	$dist = $1;
	$heading = ($heading-1) % @headings;
    }
    else {
	die "wtf $step";
    }

    my($dx,$dy) = @{$headings[$heading]};

    for (1 .. $dist) {
	$x += $dx;
	$y += $dy;

	if (!$seen && $seen{$x,$y}++) {
	    $x2 = $x;
	    $y2 = $y;
	    $seen++
	}
    }

    # printf "%s[%2d,%2d]-> %3d, %3d\n", $step,$dx,$dy, $x, $y;
    
}

printf "Solution 1: end at %d,%d = %d away\n", $x, $y, abs($x)+abs($y);
printf "Solution 2: first repeat at %d,%d = %d away\n", $x2, $y2, abs($x2)+abs($y2);
