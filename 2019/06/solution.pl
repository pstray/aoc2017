#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

my $solution1;
my $solution2;

my %dag;

while (<>) {
    if (/^(\w+)\)(\w+)$/) {
	$dag{$2} = { orbits => $1 };
    }
}

sub depth {
    my($obj) = @_;
    if ($dag{$obj}) {
	$dag{$obj}{depth} //= depth($dag{$obj}{orbits});
    }
    else {
	$dag{$obj}{depth} = 0;
    }
    return 1 + $dag{$obj}{depth};
}

for my $obj (keys %dag) {
    my $depth = depth($dag{$obj}{orbits});
    $dag{$obj}{depth} = $depth;
    $solution1 += $depth;
}

printf "Solution 1: %s\n", $solution1;

sub path {
    my($obj) = @_;
    if (my $o = $dag{$obj}{orbits}) {
	return $obj, path($o);
    }
    else {
	return $obj;
    }
}

my @you_path = path('YOU');
my @san_path = path('SAN');

shift @you_path;
shift @san_path;

my %com;

my $d = 0;
for my $obj (@you_path) {
    $com{$obj} = $d++;
}
$d = 0;
for my $obj (@san_path) {
    if (exists $com{$obj}) {
	$solution2 = $com{$obj} + $d;
	last;
    }
    $d++;
}

printf "Solution 2: %s\n", $solution2;
