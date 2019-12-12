#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;
use open ':locale';

use Data::Dumper;

$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

my $solution1;
my $solution2;

my @object;

while (<>) {
    chomp;
    if (/<x=(?<x>-?\d+), y=(?<y>-?\d+), z=(?<z>-?\d+)>/) {
	push @object, { pos => { %+ }, vel => { x => 0, y => 0, z => 0 } };
    }
    else {
	die "Kablam! $_\n";
    }
}

my %seen;

sub state {
    my @state;
    for my $o (@_) {
	push @state, @{$o->{pos}}{qw(x y z)}, @{$o->{vel}}{qw(x y z)},
    }
    return join ",", @state;
}

$seen{state(@object)}++;

my $time = 0;
while ($time < 1000) {
    $time++;

    for my $i (0 .. @object-1) {
	for my $j ($i+1 .. @object-1) {
	    for my $d (qw(x y z)) {
		if ($object[$i]{pos}{$d} < $object[$j]{pos}{$d}) {
		    $object[$i]{vel}{$d}++;
		    $object[$j]{vel}{$d}--;
		} elsif ($object[$i]{pos}{$d} > $object[$j]{pos}{$d}) {
		    $object[$i]{vel}{$d}--;
		    $object[$j]{vel}{$d}++;
		}
	    }
	}
    }

    for my $o (@object) {
	for my $d (qw(x y z)) {
	    $o->{pos}{$d} += $o->{vel}{$d};
	}
    }

    my $state = state(@object);

    if ($seen{$state}++) {
	$solution2 = $time;
    }
}

for my $o (@object) {
    $o->{pot} = 0;
    $o->{kin} = 0;
    for my $d (qw(x y z)) {
	$o->{pot} += abs($o->{pos}{$d});
	$o->{kin} += abs($o->{vel}{$d});
    }
    $o->{total} = $o->{pot} * $o->{kin};
    $solution1 += $o->{total};
}

printf "Solution 1: %s\n", join " ", $solution1;

while (!$solution2) {
    $time++;

    for my $i (0 .. @object-1) {
	for my $j ($i+1 .. @object-1) {
	    for my $d (qw(x y z)) {
		if ($object[$i]{pos}{$d} < $object[$j]{pos}{$d}) {
		    $object[$i]{vel}{$d}++;
		    $object[$j]{vel}{$d}--;
		} elsif ($object[$i]{pos}{$d} > $object[$j]{pos}{$d}) {
		    $object[$i]{vel}{$d}--;
		    $object[$j]{vel}{$d}++;
		}
	    }
	}
    }

    for my $o (@object) {
	for my $d (qw(x y z)) {
	    $o->{pos}{$d} += $o->{vel}{$d};
	}
    }

    my $state = state(@object);

    if ($seen{$state}++) {
	$solution2 = $time;
    }

    printf "t: %d\n", $time unless $time % 1000;
}

printf "Solution 2: %s\n", join " ", $solution2;
