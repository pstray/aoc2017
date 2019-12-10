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

my $map;

while (<>) {
    chomp;
    push @$map, [ split // ];
}

my $max_y = @$map - 1;
my $max_x = @{$map->[0]} - 1;

my @asteroids;
for my $y (0 .. $max_y) {
    for my $x (0 .. $max_x) {
	push @asteroids, [ $x, $y ] if $map->[$y][$x] eq '#';
    }
}

for my $from (@asteroids) {
    my($xf,$yf) = @$from;
    my $seen = 0;
    print "f $xf,$yf\n";
    for my $to (@asteroids) {
	my($xt,$yt) = @$to;

	my $xd = $xt - $xf;
	my $yd = $yt - $yf;

	next unless $xd + $yd; # from == $to;

	my $xs = $xd > 0 ? 1 : -1;
	my $ys = $yd > 0 ? 1 : -1;

	$xd = abs($xd);
	$yd = abs($yd);

	my($xi,$yi);
	if ($xd == 0) {
	    $xi = 0;
	    $yi = 1;
	}
	elsif ($yd == 0) {
	    $xi = 1;
	    $yi = 0;
	}
	elsif ($xd >= $yd) {
	    $yi = 1;
	    while ($xd*$yi % $yd) {
		$yi++;
	    }
	    $xi = $xd*$yi / $yd;
	}
	else {
	    $xi = 1;
	    while ($yd*$xi % $xd) {
		$xi++;
	    }
	    $yi = $yd*$xi / $xd;
	}

	$xi *= $xs;
	$yi *= $ys;

	print "  -> ($xt,$yt) <$xd,$yd> { $xi, $yi }\n";

	my($x,$y) = ($xf+$xi,$yf+$yi);
	my $obscured = 0;

      LOF:
	while (!$obscured &&
	       $x*$xs <= $xt*$xs &&
	       $y*$ys <= $yt*$ys
	      ) {
	    print "    [$x,$y]";
	    unless ($x == $xt && $y == $yt) {
		if ($map->[$y][$x] eq '#') {
		    $obscured++;
		    printf " O";
		}
	    }
	    print "\n";
	    $x += $xi;
	    $y += $yi;
	}
	$seen++ unless $obscured;
    }
    print "  = $seen\n";
    if ($seen > $solution1) {
	$solution1 = "$seen $xf $yf";
    }
}

printf "Solution 1: %s\n", $solution1;


printf "Solution 2: %s\n", $solution2;
