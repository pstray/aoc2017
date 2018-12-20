#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;
$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

use Getopt::Long;

my $color = 0;

GetOptions('c|color!' => \$color);


my $re = do { local $/ = undef; <> };
unless ($re =~ s/.*\^([NESW|()]*)\$.*/$1/s) {
    die "Invalid input\n";
}

our($cx,$cy);
my($map, $x_min, $x_max, $y_min, $y_max) = generate_map($re);

# draw_map($map, $x_min, $x_max, $y_min, $y_max);

my $dmap = {};
my $dmax;

{
    local $map->{0}{0} = '.';
    $dmax = fill_distance($map,$dmap,0,0,0);
}

draw_map($map, $x_min, $x_max, $y_min, $y_max, $dmap);

printf "Solution 1: max shortest distance from X = %d\n", $dmax;

my $ans2 = 0;
for my $yy (keys %$dmap) {
    for my $xx (keys %{$dmap->{$yy}}) {
	$ans2++ if $dmap->{$yy}{$xx} >= 1000;
    }
}

printf "Solution 2: rooms at least 1000 doors away = %d\n", $ans2;

exit;

sub fill_distance {
    my($map,$dmap,$x,$y,$dist) = @_;

    return unless $map->{$y}{$x} eq '.';

    my $d = $dmap->{$y}{$x};

    if (defined($d) && $d < $dist) {
	return;
    }

    $dmap->{$y}{$x} = $dist;

    my $dmax = $dist;
    my $d;

    if ($map->{$y-1}{$x} eq '-') {
	my $d = fill_distance($map,$dmap,$x,$y-2,$dist+1);
	$dmax = $d if $d > $dmax;
    }

    if ($map->{$y+1}{$x} eq '-') {
	my $d = fill_distance($map,$dmap,$x,$y+2,$dist+1);
	$dmax = $d if $d > $dmax;
    }

    if ($map->{$y}{$x-1} eq '|') {
	my $d = fill_distance($map,$dmap,$x-2,$y,$dist+1);
	$dmax = $d if $d > $dmax;
    }

    if ($map->{$y}{$x+1} eq '|') {
	my $d = fill_distance($map,$dmap,$x+2,$y,$dist+1);
	$dmax = $d if $d > $dmax;
    }

    return $dmax;
}


sub generate_map_recurse {
    my($re,$pos,$plist,$map,$level) = @_;
    my @slist = map { { %$_ } } @$plist;
    my(@nlist);

    while (@$re) {
	my $c = shift @$re;
	if ($c eq 'N') {
	    for my $p (@$plist) {
		my($x,$y) = ($p->{x},$p->{y});
		$map->{$y-1}{$x  }   = '-';
		$map->{$y-2}{$x-1} //= '?';
		$map->{$y-2}{$x  } //= '.';
		$map->{$y-2}{$x+1} //= '?';
		$map->{$y-3}{$x-1}   = '#';
		$map->{$y-3}{$x  } //= '?';
		$map->{$y-3}{$x+1}   = '#';
		$p->{y} -= 2;
	    }
	}
	elsif ($c eq 'E') {
	    for my $p (@$plist) {
		my($x,$y) = ($p->{x},$p->{y});
		$map->{$y  }{$x+1}   = '|';
		$map->{$y-1}{$x+2} //= '?';
		$map->{$y  }{$x+2} //= '.';
		$map->{$y+1}{$x+2} //= '?';
		$map->{$y-1}{$x+3}   = '#';
		$map->{$y  }{$x+3} //= '?';
		$map->{$y+1}{$x+3}   = '#';
		$p->{x} += 2;
	    }
	}
	elsif ($c eq 'S') {
	    for my $p (@$plist) {
		my($x,$y) = ($p->{x},$p->{y});
		$map->{$y+1}{$x  }   = '-';
		$map->{$y+2}{$x-1} //= '?';
		$map->{$y+2}{$x  } //= '.';
		$map->{$y+2}{$x+1} //= '?';
		$map->{$y+3}{$x-1}   = '#';
		$map->{$y+3}{$x  } //= '?';
		$map->{$y+3}{$x+1}   = '#';
		$p->{y} += 2;
	    }
	}
	elsif ($c eq 'W') {
	    for my $p (@$plist) {
		my($x,$y) = ($p->{x},$p->{y});
		$map->{$y  }{$x-1}   = '|';
		$map->{$y-1}{$x-2} //= '?';
		$map->{$y  }{$x-2} //= '.';
		$map->{$y+1}{$x-2} //= '?';
		$map->{$y-1}{$x-3}   = '#';
		$map->{$y  }{$x-3} //= '?';
		$map->{$y+1}{$x-3}   = '#';
		$p->{x} -= 2;
	    }
	}
	elsif ($c eq '(') {
	    generate_map_recurse($re, $pos, $plist, $map, $level+1);
	}
	elsif ($c eq '|') {
	    # store old previous positions
	    push @nlist, @$plist;
	    # start again on new branch
	    @$plist = map { { %$_ } } @slist;
	}
	elsif ($c eq ')') {
	    push @nlist, @$plist;
	    my %seen;
	    @$plist = grep { !$seen{$_->{x},$_->{y}}++ } @nlist;
	    return;
	}
    }
    if (@nlist) {
	warn "branches presen at end of data...\n";
    }
    return:
}

sub generate_map {
    my($re) = @_;
    my($x_min,$x_max,$y_min,$y_max) = (0) x 4;
    my $map = {};
    $map->{-1}{-1} = '#';
    $map->{-1}{ 0} = '?';
    $map->{-1}{+1} = '#';
    $map->{ 0}{-1} = '?';
    $map->{ 0}{ 0} = 'X';
    $map->{ 0}{+1} = '?';
    $map->{+1}{-1} = '#';
    $map->{+1}{ 0} = '?';
    $map->{+1}{+1} = '#';

    generate_map_recurse([split //, $re], 0, [{x=>0, y=>0}], $map);

    for my $y (keys %$map) {
	$y_min = $y if $y < $y_min;
	$y_max = $y if $y > $y_max;
	for my $x (keys %{$map->{$y}}) {
	    $x_min = $x if $x < $x_min;
	    $x_max = $x if $x > $x_max;
	    $map->{$y}{$x} = '#' if $map->{$y}{$x} eq '?';
	}
    }
    return wantarray ? ($map,$x_min,$x_max,$y_min,$y_max) : $map;
}

sub draw_map {
    my($map,$x_min,$x_max,$y_min,$y_max,$overlay) = @_;
    my $m = "";
    for my $y ($y_min .. $y_max) {
	for my $x ($x_min .. $x_max) {
	    my $c = $overlay->{$y}{$x} // $map->{$y}{$x} // ' ';
	    my($fg,$bg);
	    if ($c =~ /^\d+$/) {
		$fg = 12;
		$bg = int(255-$c/2);
		$bg = 232 if $bg < 232;
		$c = (0..9,'a'..'z')[$c] // '.';
	    }
	    if ($color) {
		$c = ($bg?"\e[48;5;${bg}m":"") . ($fg?"\e[38;5;${fg}m":"") . $c . ($fg||$bg?"\e[m":"");
	    }
	    $m .= $c;
	}
	$m .= "\n";
    }
    if ($color) {
	for ($m) {
	    s/([|-]+)/\e[38;5;10m$1\e[m/g;
	    s/(\#+)/\e[38;5;136m$1\e[m/g;
	    s/(\.+)/\e[38;5;242m$1\e[m/g;
	}
    }
    print $m;
}
