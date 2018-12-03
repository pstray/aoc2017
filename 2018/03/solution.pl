#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

my %data;
my %ids;

while (<>) {
    chomp;
    if (my ($id,$x,$y,$w,$h) = /#(\d+)\s+@\s+(\d+),(\d+):\s+(\d+)x(\d+)/) {
	$ids{$id}++;
	for my $xx ($x .. $x+$w-1) {
	    for my $yy ($y .. $y+$h-1) {
		push @{$data{$xx}{$yy}}, $id;
	    }
	}
    }
    else {
	warn "Unparsable input: $_\n";
    }
}

my $overlaps = 0;
my @no_overlap_ids;
for my $x (keys %data) {
    for my $y (keys %{$data{$x}}) {
	my @ids = @{$data{$x}{$y}};
	if (@ids>1) {
	    $overlaps++;
	    delete $ids{$_} for @ids;
	}
    }
}

printf "Solution 1: %d\n", $overlaps;
printf "Solution 2: %s\n", join ", ", keys %ids;
