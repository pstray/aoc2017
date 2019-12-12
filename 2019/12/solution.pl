#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;
use open ':locale';

use Data::Dumper;

eval { require "../../lib/common.pl"; };

my $solution1;
my $solution2;

my @objects;

while (<>) {
    chomp;
    if (/<x=(?<x>-?\d+), y=(?<y>-?\d+), z=(?<z>-?\d+)>/) {
	push @objects, { pos => { %+ }, vel => { x => 0, y => 0, z => 0 } };
    }
    else {
	die "Kablam! $_\n";
    }
}

sub state {
    my($axis,@objects) = @_;
    my @state;
    for my $o (@objects) {
	push @state, $o->{pos}{$axis}, $o->{vel}{$axis};
    }
    return join ",", @state;
}

my %init;
for my $axis (qw(x y z)) {
    $init{$axis} = state($axis,@objects);
}

my %axis_loop;

my $time = 0;
while ($time < 1000) {
    $time++;

    for my $i (0 .. @objects-1) {
	for my $j ($i+1 .. @objects-1) {
	    for my $d (qw(x y z)) {
		if ($objects[$i]{pos}{$d} < $objects[$j]{pos}{$d}) {
		    $objects[$i]{vel}{$d}++;
		    $objects[$j]{vel}{$d}--;
		} elsif ($objects[$i]{pos}{$d} > $objects[$j]{pos}{$d}) {
		    $objects[$i]{vel}{$d}--;
		    $objects[$j]{vel}{$d}++;
		}
	    }
	}
    }

    for my $o (@objects) {
	for my $d (qw(x y z)) {
	    $o->{pos}{$d} += $o->{vel}{$d};
	}
    }

    unless ($solution2) {
	for my $axis (qw(x y z)) {
	    next if $axis_loop{$axis};
	    my $state = state($axis,@objects);
	    next unless $state eq $init{$axis};
	    $axis_loop{$axis} = $time;
	}

	if (3 == grep { $_ } values %axis_loop) {
	    $solution2 = lcm(values %axis_loop);
	}

    }

}

for my $o (@objects) {
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

    for my $i (0 .. @objects-1) {
	for my $j ($i+1 .. @objects-1) {
	    for my $d (qw(x y z)) {
		if ($objects[$i]{pos}{$d} < $objects[$j]{pos}{$d}) {
		    $objects[$i]{vel}{$d}++;
		    $objects[$j]{vel}{$d}--;
		} elsif ($objects[$i]{pos}{$d} > $objects[$j]{pos}{$d}) {
		    $objects[$i]{vel}{$d}--;
		    $objects[$j]{vel}{$d}++;
		}
	    }
	}
    }

    for my $o (@objects) {
	for my $d (qw(x y z)) {
	    $o->{pos}{$d} += $o->{vel}{$d};
	}
    }

    for my $axis (qw(x y z)) {
	next if $axis_loop{$axis};
	my $state = state($axis,@objects);
	next unless $state eq $init{$axis};
	printf "%s loops at %s\n", $axis, $time;
	$axis_loop{$axis} = $time;
    }

    if (3 == grep { $_ } values %axis_loop) {
	$solution2 = lcm(values %axis_loop);
    }
}

printf "Solution 2: %s\n", join " ", $solution2;
