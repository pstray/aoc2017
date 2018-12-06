#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

my %grid;
my %x_dim;
my %y_dim;
my @coords;
my %cc;

my @id = ("A" .. "Z", "a" .. "z");

while (<>) {
    chomp;
    if (/^(\d+)\s*,\s*(\d+)$/) {
	$cc{$1}{$2} = $id[@coords];
	push @coords, [ $1, $2 ];
	$x_dim{$1}++;
	$y_dim{$2}++;
    }
    else {
	warn "Unparsable input: $_\n";
    }
}

use Data::Dumper;

my @x_dim = sort {$a<=>$b} keys %x_dim;
my @y_dim = sort {$a<=>$b} keys %y_dim;

my $x_min = $x_dim[0];
my $x_max = $x_dim[-1];
my $y_min = $y_dim[0];
my $y_max = $y_dim[-1];

for my $y ($y_min .. $y_max) {
    for my $x ($x_min .. $x_max) {
	my @d;
	for my $c (0 .. @coords-1) {
	    my($cx,$cy) = @{$coords[$c]};
	    my $d = abs($x-$cx)+abs($y-$cy);
	    push @d, [ $d, 0+@d ];
	}
	my($min_d) = sort {$a<=>$b} map {$_->[0]} @d;
	my(@min_id) = map { $_->[1] } grep { $_->[0] == $min_d } @d;
	if (@min_id>1) {
	    $grid{$x}{$y} = -1;
	    #print ".";
	}
	else {
	    $grid{$x}{$y} = $min_id[0];
	    #printf "%c", ord("a")+$min_id[0];
	}
    }
    #printf "\n";
}

my %infinite;
for my $x ($x_min .. $x_max) {
    $infinite{$grid{$x}{$y_min}}++;
    $infinite{$grid{$x}{$y_max}}++;
}
for my $y ($y_min .. $y_max) {
    $infinite{$grid{$x_min}{$y}}++;
    $infinite{$grid{$x_max}{$y}}++;
}

my %area;
for my $y ($y_min .. $y_max) {
    for my $x ($x_min .. $x_max) {
	my $id = $grid{$x}{$y};
	$area{$id}++ unless $infinite{$id};
    }
}

#print Dumper \%area;

my($s1) = sort{$b<=>$a} values %area;

printf "Solution 1: %d\n", $s1;

my $s2 = 0;
my $off = 10;
for my $y ($y_min-$off .. $y_max+$off) {
    for my $x ($x_min-$off .. $x_max+$off) {

	my $d = 0;
	for my $c (@coords) {
	    my($cx,$cy) = @$c;
	    $d += abs($x-$cx) + abs($y-$cy);
	}

	if ($d < 10000) {
	    $s2++;
	    # printf "%s", $cc{$x}{$y} || "#"; #($d/1000)%10;
	}
	else {
	    # printf "%s", $cc{$x}{$y} || ".";
	}
    }
    # print "\n";
}

printf "Solution 2: %d\n", $s2;
