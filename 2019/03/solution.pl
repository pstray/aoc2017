#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my $solution1;
my $solution2;

my %grid;

my $all_mask;

while (<>) {
    my($x,$y) = (0,0);
    chomp;
    my @line = split /,/;
    my $wire_mask = 2 ** ($. - 1);
    my $wire_length = 0;
    $all_mask |= $wire_mask;
    for my $s (@line) {
	if ($s =~ /^R(\d+)$/) {
	    for (1 .. $1) {
		++$x;
		++$wire_length;
		$grid{$y}{$x}{X} |= $wire_mask;
		push @{$grid{$y}{$x}{L}}, $wire_length;
	    }
	}
	elsif ($s =~ /^U(\d+)$/) {
	    for (1 .. $1) {
		++$y;
		++$wire_length;
		$grid{$y}{$x}{X} |= $wire_mask;
		push @{$grid{$y}{$x}{L}}, $wire_length;
	    }
	}
	elsif ($s =~ /^L(\d+)$/) {
	    for (1 .. $1) {
		--$x;
		++$wire_length;
		$grid{$y}{$x}{X} |= $wire_mask;
		push @{$grid{$y}{$x}{L}}, $wire_length;
	    }
	}
	elsif ($s =~ /^D(\d+)$/) {
	    for (1 .. $1) {
		--$y;
		++$wire_length;
		$grid{$y}{$x}{X} |= $wire_mask;
		push @{$grid{$y}{$x}{L}}, $wire_length;
	    }
	}
	else {
	    die "Kablam! $. $s\n";
	}
    }
}

my @cross_dist;
my @cross_length;

for my $y (keys %grid) {
    for my $x (keys %{$grid{$y}}) {
	next unless $grid{$y}{$x}{X} == $all_mask;
	push @cross_dist, abs($x)+abs($y);
	my $sum = 0;
	$sum += $_ for @{$grid{$y}{$x}{L}};
	push @cross_length, $sum;
	#printf "Cross at $x,$y\n";
    }
}

($solution1) = sort {$a <=> $b} @cross_dist;
($solution2) = sort {$a <=> $b} @cross_length;

printf "Solution 1: %s\n", $solution1;
printf "Solution 2: %s\n", $solution2;
