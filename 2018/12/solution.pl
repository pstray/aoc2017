#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

$| = 1;

my $state = "";
my %rules;

while (<>) {
    chomp;
    if (/^initial state: ([.#]+)/) {
	$state = $1;
    }
    elsif (/([.#]+) => #/) {
	$rules{$1}++;
    }
}

my $index = 0;

while ($state !~ /^\.\.\./) {
    $index--;
    $state = ".${state}";
}
while ($state =~ /^\.\.\.\./) {
    $index++;
    $state = substr $state, 1;
}
while ($state !~ /\.\.\.$/) {
    $state = "${state}.";
}

my $generation = 0;
my %seen = ( $state => $generation );

printf("  %s %d @ %d\n", $state, $index, $generation);

for my $g (1 .. 20) {
    $generation++;
    my $s = "..";
    for my $i (0 .. length($state)-3) {
	$s .= $rules{substr($state,$i,5)} ? "#" : ".";
    }
    $state = $s;
    while ($state !~ /^\.\.\./) {
	$index--;
	$state = ".${state}";
    }
    while ($state =~ /^\.\.\.\./) {
	$index++;
	$state = substr $state, 1;
    }
    while ($state !~ /\.\.\.$/) {
	$state = "${state}.";
    }
    printf("  %s %d @ %d\n", $state, $index, $generation);
    $seen{$state} = [ $generation, $index ];
}

my $sum = 0;
for my $i (0 .. length($state)-1) {
    if (substr($state,$i,1) eq "#") {
	$sum += $i+$index;
    }
}

printf "Solution 1: after %d gens, sum of pots = %d\n", $generation, $sum;

my $max_generation = 50000000000;
while ($generation < $max_generation) {
    
    $generation++;
    my $s = "..";
    for my $i (0 .. length($state)-3) {
	
	$s .= $rules{substr($state,$i,5)} ? "#" : ".";
    }
    $state = $s;
    while ($state !~ /^\.\.\./) {
	$index--;
	$state = ".${state}";
    }
    while ($state =~ /^\.\.\.\./) {
	$index++;
	$state = substr $state, 1;
    }
    while ($state !~ /\.\.\.$/) {
	$state = "${state}.";
    }
    printf "\r  %d", $generation unless $generation % 1000;

    if (my $i = $seen{$state}) {
	my($gen,$idx) = @$i;
	my $g_diff = $generation-$gen;
	my $i_diff = $index-$idx;

	my $skip = int(($max_generation-$generation) / $g_diff);
	$generation += $skip*$g_diff;
	$index += $skip*$i_diff;
	while ($generation+$g_diff < $max_generation) {
	    $generation += $g_diff;
	    $index += $i_diff;
	}
    }
    printf("  %s %d @ %d\n", $state, $index, $generation);

    $seen{$state} = [ $generation, $index ];
}

my $sum2 = 0;
for my $i (0 .. length($state)-1) {
    if (substr($state,$i,1) eq "#") {
	$sum2 += $i+$index;
    }
}

printf "Solution 2: after %d gens, sum of pots = %d\n", $generation, $sum2;
