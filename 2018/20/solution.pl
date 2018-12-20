#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;
$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

my $re = do { local $/ = undef; <> };
unless ($re =~ s/.*\^([NESW|()]*)\$.*/$1/s) {
    die "Invalid input\n";
}

my($map, $x_min, $x_max, $y_min, $y_max) = generate_map($re);

draw_map($map, $x_min, $x_max, $y_min, $y_max);

exit;

sub generate_map_recurse {
    my($re,$pos,$x,$y,$map) = @_;

    while ($pos < @$re) {
	my $c = $re->[$pos++];
	if ($c eq 'N') {
	    $map->{$y-1}{$x  }   = '-';
	    $map->{$y-2}{$x-1} //= '?';
	    $map->{$y-2}{$x  }   = '.';
	    $map->{$y-2}{$x+1} //= '?';
	    $map->{$y-3}{$x-1}   = '#';
	    $map->{$y-3}{$x  } //= '?';
	    $map->{$y-3}{$x+1}   = '#';
	    $y -= 2;
	}
	elsif ($c eq 'E') {
	    $map->{$y  }{$x+1}   = '|';
	    $map->{$y-1}{$x+2} //= '?';
	    $map->{$y  }{$x+2}   = '.';
	    $map->{$y+1}{$x+2} //= '?';
	    $map->{$y-1}{$x+3}   = '#';
	    $map->{$y  }{$x+3} //= '?';
	    $map->{$y+1}{$x+3}   = '#';
	    $x += 2;
	}
	elsif ($c eq 'S') {
	    $map->{$y+1}{$x  }   = '-';
	    $map->{$y+2}{$x-1} //= '?';
	    $map->{$y+2}{$x  }   = '.';
	    $map->{$y+2}{$x+1} //= '?';
	    $map->{$y+3}{$x-1}   = '#';
	    $map->{$y+3}{$x  } //= '?';
	    $map->{$y+3}{$x+1}   = '#';
	    $y += 2;
	}
	elsif ($c eq 'W') {
	    $map->{$y  }{$x-1}   = '|';
	    $map->{$y-1}{$x-2} //= '?';
	    $map->{$y  }{$x-2}   = '.';
	    $map->{$y+1}{$x-2} //= '?';
	    $map->{$y-1}{$x-3}   = '#';
	    $map->{$y  }{$x-3} //= '?';
	    $map->{$y+1}{$x-3}   = '#';
	    $x -= 2;
	}

    }

    
}

sub generate_map {
    my($re) = @_;
    my $cx = length($re)*4;  # just to make sure we stay positive ;)
    my $cy = $cx;
    my($x_min,$x_max,$y_min,$y_max) = ($cx,$cx,$cy,$cy);
    my $map = {};
    $map->{$cy-1}{$cx-1} = '#';
    $map->{$cy-1}{$cx  } = '?';
    $map->{$cy-1}{$cx+1} = '#';
    $map->{$cy  }{$cx-1} = '?';
    $map->{$cy  }{$cx  } = 'X';
    $map->{$cy  }{$cx+1} = '?';
    $map->{$cy+1}{$cx-1} = '#';
    $map->{$cy+1}{$cx  } = '?';
    $map->{$cy+1}{$cx+1} = '#';
    generate_map_recurse([split //, $re],0,$cx,$cy,$map);

    for my $y (keys %$map) {
	$y_min = $y if $y < $y_min;
	$y_max = $y if $y > $y_max;
	for my $x (keys %{$map->{$y}}) {
	    $x_min = $x if $x < $x_min;
	    $x_max = $x if $x > $x_max;
	    #$map->{$y}{$x} = '#' if $map->{$y}{$x} eq '?';
	}
    }
    return wantarray ? ($map,$x_min,$x_max,$y_min,$y_max) : $map;
}

sub draw_map {
    my($map,$x_min,$x_max,$y_min,$y_max) = @_;
    for my $y ($y_min .. $y_max) {
	for my $x ($x_min .. $x_max) {
	    printf "%1s", $map->{$y}{$x};
	}
	printf "\n";
    }
}

  

