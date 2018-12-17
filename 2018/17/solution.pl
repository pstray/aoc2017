#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my %color_map =
  ( '#' => 3,
    '.' => 242,
    '~' => 6,
    '|' => 4,
  );
my @color_map_rgb;

my %map;
my($min_x,$max_x,$min_y,$max_y);

$min_x = $max_x = 500;
$min_y = 5000000;
$max_y = 0;

while (<>) {
    chomp;
    if (my($x,$y1,$y2) = /^x=(\d+),\s*y=(\d+)\.\.(\d+)$/) {
	$min_x = $x if $x < $min_x;
	$max_x = $x if $x > $max_x;
	for my $y ($y1 .. $y2) {
	    $min_y = $y if $y < $min_y;
	    $max_y = $y if $y > $max_y;
	    $map{$y}{$x} = '#';
	}

    }
    elsif (my($y,$x1,$x2) = /^y=(\d+),\s*x=(\d+)\.\.(\d+)$/) {
	$min_y = $y if $y < $min_y;
	$max_y = $y if $y > $max_y;
	for my $x ($x1 .. $x2) {
	    $min_x = $x if $x < $min_x;
	    $max_x = $x if $x > $max_x;
	    $map{$y}{$x} = '#';
	}
    }
    else {
	warn "unparsable line:$.: $_\n";
    }

}

#print_map("Initial map ($min_x..$max_x, $min_y..$max_y)", $min_x, $min_y, $max_x, $max_y,\%map);

my %state;

flow_water(500,0,\%map,\%state);

# print_map("Water flow", $min_x, $min_y, $max_x, $max_y,\%map,\%state);
save_map("solution", $min_x-5, $min_y, $max_x+5, $max_y, \%map, \%state);

my $wet_sand = 0;
my $water_stored = 0;

for my $y ($min_y .. $max_y) {
    for my $x ($min_x .. $max_x) {
	$wet_sand += $map{$y}{$x} =~ /[~|]/;
	$water_stored += $map{$y}{$x} eq '~';
    }
}

printf "Solution 1: %d wet sand\n", $wet_sand;
printf "Solution 2: %d water stored\n", $water_stored;

exit;

sub flow_water {
    my($x,$y,$map,$state,$dir) = @_;
    return if $y > $max_y;
    return -1 if $map{$y}{$x} =~ /[|]/;
    return $x-$dir if $map{$y}{$x};
    $map{$y}{$x} //= '|';
    $min_x = $x if $x < $min_x;
    $max_x = $x if $x > $max_x;

    if (0) {
	local $state{$y}{$x} = '@';
	print_map("Water flow ($dir)", $min_x, $min_y, $max_x, $max_y,\%map,\%state);
    }

    # flow down
    my $fd = flow_water($x,$y+1,$map,$state,0);
    if ($fd>0) {
	my($fl,$fr);
	$fl = flow_water($x-1,$y,$map,$state,-1) unless $dir == 1;
	return $fl if $dir == -1;
	my $fr = flow_water($x+1,$y,$map,$state,+1);
	return $fr if $dir == 1;

	# print "[$fl] [$fr]\n";

	if ($fl>0 && $fr>0) {
	    for my $x ($fl .. $fr) {
		$map{$y}{$x} = '~';
	    }
	    return $x;
	}
	else {

	}
    }
    else {
	return $fd;
    }
}

sub print_map {
    my($label,$x1,$y1,$x2,$y2,$map,$overlay) = @_;
    printf "map: %s:\n", $label;
    for my $y ($y1 .. $y2) {
	for my $x ($x1 .. $x2) {
	    my $color;
	    my $bg;
	    my $c = $overlay->{$y}{$x} || $map->{$y}{$x};
	    if (ref $c) {
		$color = $c->{color};
		$bg = $c->{bg};
		$c = $c->{map};
	    }
	    if ($c =~ /^\d+$/) {
		$bg = int(255-$c/2);
		$bg = 232 if $bg < 232;
		$c = (0..9,'a'..'z')[$c] // 'X';
	    }
	    $c //= '.';
	    $color //= $color_map{$c};
	    $c = "\e[38;5;${color}m$c" if defined $color;
	    $c = "\e[48;5;${bg}m$c" if defined $bg;
	    $c .= "\e[m" if $color || $bg;
	    printf("%1s", $c);
	}
	printf "\n";
    }
    print "\n";
}

sub save_map {
    my($file,$x1,$y1,$x2,$y2,$map,$overlay) = @_;

    unless (@color_map_rgb) {
	for my $blue (0, 1) {
	    for my $green (0, 1) {
		for my $red (0, 1) {
		    $color_map_rgb[$red + $green * 2 + $blue * 4] =
		      sprintf("#%02x%02x%02x",
			      map { $_ * 191 } $red, $green, $blue);
		    $color_map_rgb[8 + $red + $green * 2 + $blue * 4] =
		      sprintf("#%02x%02x%02x",
			      map { $_ * 255 } $red, $green, $blue);
		}
	    }
	}
	$color_map_rgb[8] = "#7F7F7F";

	# colors 16-231 are a 6x6x6 color cube
	for my $red (0..5) {
	    for my $green (0..5) {
		for my $blue (0..5) {
		    $color_map_rgb[16 + $red * 36 + $green * 6 + $blue] =
		      sprintf("#%02x%02x%02x",
			      map { $_ ? $_ * 40 + 55 : 0 } $red, $green, $blue);
		}
	    }
	}

	# colors 232-255 are a grayscale ramp, intentionally leaving out
	# black and white
	for my $gray (0 .. 23) {
	    $color_map_rgb[232 + $gray] =
	      sprintf("#%02x%02x%02x", ($gray * 10 + 8) x 3);
	}
    }

    my %colors;
    my @data;
    for my $y ($y1 .. $y2) {
	my $line = "";
	for my $x ($x1 .. $x2) {
	    my $color;
	    my $c = $overlay->{$y}{$x} || $map->{$y}{$x};
	    $c //= '.';
	    $color = $color_map{$c};
	    $colors{$c} ||= "$c c $color_map_rgb[$color]";
	    $line .= "$c";
	}
	push @data, $line;
    }
    $colors{" "} //= "  c None";
    open my $xpm, ">", "$file.xpm";
    printf $xpm "/* XPM */\nstatic char * %s[] = {\n", $file;
    printf $xpm qq{"%d %d %d 1",\n}, $x2-$x1+1, $y2-$y1+1, 0+keys %colors;
    for my $c (sort values %colors) {
	printf $xpm qq{"%s",\n}, $c;
    }
    for my $l (@data) {
	printf $xpm qq{"%s",\n}, $l
    }
    printf $xpm qq("AoC"};\n);
    close $xpm;
}
