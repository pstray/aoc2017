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
for my $x (0 .. $max_x) {
    for my $y (0 .. $max_y) {
	push @asteroids, [ $x, $y ] if $map->[$y][$x] eq '#';
    }
}

#print Dumper \@asteroids;

my($station_x, $station_y);

for my $from (@asteroids) {
    my($xf,$yf) = @$from;
    my $seen = 0;
    # print "f $xf,$yf\n";
    for my $to (@asteroids) {
	my($xt,$yt) = @$to;

	my $xd = $xt - $xf;
	my $yd = $yt - $yf;

	my $xs = $xd > 0 ? 1 : -1;
	my $ys = $yd > 0 ? 1 : -1;

	$xd = abs($xd);
	$yd = abs($yd);

	next unless $xd + $yd; # from == $to;

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

	# print "  -> ($xt,$yt) <$xd,$yd> { $xi, $yi }\n";

	my($x,$y) = ($xf+$xi,$yf+$yi);
	my $obscured = 0;

      LOF:
	while (!$obscured &&
	       $x*$xs <= $xt*$xs &&
	       $y*$ys <= $yt*$ys
	      ) {
	    # print "    [$x,$y]";
	    unless ($x == $xt && $y == $yt) {
		if ($map->[$y][$x] eq '#') {
		    $obscured++;
		    # printf " O";
		}
	    }
	    # print "\n";
	    $x += $xi;
	    $y += $yi;
	}
	$seen++ unless $obscured;
    }
    # print "  = $seen\n";
    if ($seen > $solution1) {
	$solution1 = $seen;
	$station_x = $xf;
	$station_y = $yf;
    }
}

printf "Solution 1: %s\n", join " ", $solution1, $station_x, $station_y;

my %targets;
my $pi = 4*atan2(1,1);

for my $asteroid (@asteroids) {
    my($ax,$ay) = @$asteroid;
    my $xd = $ax - $station_x;
    my $yd = $ay - $station_y;
    next unless $xd || $yd;
    my $d = sqrt($xd ** 2 + $yd ** 2);
    my $ang = 90 - atan2(-$yd,$xd)*180/$pi;
    $ang += 360 if $ang < 0;

    push @{$targets{$ang}}, [ $d, $ax, $ay ];
}

for my $ang (sort { $a <=> $b } keys %targets) {
    $targets{$ang} = [ sort { $a->[0] <=> $b->[0] } @{$targets{$ang}} ];
}

my $n = 0;

TARGET:
while (1) {
    my $seen = 0;
    for my $ang (sort { $a <=> $b } keys %targets) {
	$seen++;
	$n++;
	my $l = $targets{$ang};
	# printf "%7.4f = %s", $ang, Dumper $l;

	my $a = shift @$l;
	delete $targets{$ang} unless @$l;
	my $ax = $a->[1];
	my $ay = $a->[2];
	$solution2 = $ax*100 + $ay;
	# printf "=== %3d %7.4f %3d %3d %6.2f\n", $n, $ang, $ax, $ay, $a->[0];
	last TARGET if $n >= 200;
    }
    last unless $seen;
}


printf "Solution 2: %s\n", join " ", $solution2, $n;
