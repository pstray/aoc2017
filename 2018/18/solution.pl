#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;
use Getopt::Long;

$| = 1;

my @map;

my $max_x;
my $max_y;
my $animate = 0;

GetOptions( 'a|animate!' => \$animate,
	  );

while (<>) {
    chomp;
    my @line = split //;
    push @map, [@line];
    $max_x = @line-1;
    $max_y++;
}

my $minute = 0;

my %seen;

while ($minute < 10) {
    my $map = "";
    my @nmap;
    for my $y (0 .. @map-1) {
	my @line;
	for my $x (0 .. @{$map[$y]}) {
	    my $type = $map[$y][$x];
	    my %types;
	    if ($y > 0) {
		$types{$map[$y-1][$x-1]}++ if $x > 0;
		$types{$map[$y-1][$x  ]}++;
		$types{$map[$y-1][$x+1]}++ if $x < $max_x;
	    }
	    $types{$map[$y][$x-1]}++ if $x > 0;
	    $types{$map[$y][$x+1]}++ if $x < $max_x;
	    if ($y < $max_y) {
		$types{$map[$y+1][$x-1]}++ if $x > 0;
		$types{$map[$y+1][$x  ]}++;
		$types{$map[$y+1][$x+1]}++ if $x < $max_x;
	    }
	    my $ntype = $type;
	    if ($type eq '.') {
		$ntype = $types{"|"} >= 3 ? "|" : ".";
	    }
	    elsif ($type eq '|') {
		$ntype = $types{"#"} >= 3 ? "#" : "|";
	    }
	    elsif ($type eq '#') {
		$ntype = $types{"#"}>0 && $types{"|"}>0 ? "#" : ".";
	    }
	    push @line, $ntype;
	    $map .= $ntype;
	}
	push @nmap, [@line];
	$map .= "\n";
    }
    @map = @nmap;
    printf "After minute %d\n", ++$minute;
    printf $map;
    printf "\n";
}

my %ttypes;
for my $y (0 .. @map-1) {
    for my $x (0 .. @{$map[$y]}) {
	$ttypes{$map[$y][$x]}++;
    }
}
printf "Solution 1: %d trees and %d lumberyards = %d\n",
  $ttypes{"|"}, $ttypes{"#"},  $ttypes{"|"} * $ttypes{"#"};

my %seen;
my $skipped = 0;
my $max_time = 1000000000;
while ($minute < $max_time) {
    $minute++;
    my $map = "";
    my @nmap;
    for my $y (0 .. @map-1) {
	my @line;
	for my $x (0 .. @{$map[$y]}) {
	    my $type = $map[$y][$x];
	    my %types;
	    if ($y > 0) {
		$types{$map[$y-1][$x-1]}++ if $x > 0;
		$types{$map[$y-1][$x  ]}++;
		$types{$map[$y-1][$x+1]}++ if $x < $max_x;
	    }
	    $types{$map[$y][$x-1]}++ if $x > 0;
	    $types{$map[$y][$x+1]}++ if $x < $max_x;
	    if ($y < $max_y) {
		$types{$map[$y+1][$x-1]}++ if $x > 0;
		$types{$map[$y+1][$x  ]}++;
		$types{$map[$y+1][$x+1]}++ if $x < $max_x;
	    }
	    my $ntype = $type;
	    if ($type eq '.') {
		$ntype = $types{"|"} >= 3 ? "|" : ".";
	    }
	    elsif ($type eq '|') {
		$ntype = $types{"#"} >= 3 ? "#" : "|";
	    }
	    elsif ($type eq '#') {
		$ntype = $types{"#"}>0 && $types{"|"}>0 ? "#" : ".";
	    }
	    push @line, $ntype;
	    $map .= $ntype;
	}
	push @nmap, [@line];
	$map .= "\n";
    }
    @map = @nmap;

    if ($animate) {
	printf "After minute %d\n", $minute;
	for ($map) {
	    s/(\|+)/\e[38;5;10m$1\e[m/g;
	    s/(\#+)/\e[38;5;214m$1\e[m/g;
	    s/(\.+)/\e[38;5;242m$1\e[m/g;
	}
	printf $map;
	printf "\n";
    }

    unless ($skipped) {
	my $seen = $seen{$map};
	if ($seen) {
	    $skipped = 1;
	    my $diff = $minute-$seen;
	    my $left = $max_time-$minute;
	    printf "At time %d, same seen %d minutes ago", $minute, $diff;
	    $minute += $diff*int($left/$diff);
	    printf ", skipping ahead to %d\n", $minute;
	}
    }
    $seen{$map} = $minute;
}

%ttypes = ();
for my $y (0 .. @map-1) {
    for my $x (0 .. @{$map[$y]}) {
	$ttypes{$map[$y][$x]}++;
    }
}

printf "Solution 2: %d trees and %d lumberyards after state %d = %d\n",
  $ttypes{"|"}, $ttypes{"#"}, $minute, $ttypes{"|"} * $ttypes{"#"};
