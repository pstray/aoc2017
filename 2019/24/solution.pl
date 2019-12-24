#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;
use open ':locale';

use POSIX qw(ceil);
use Time::HiRes qw(sleep);

use Data::Dumper;

eval { require "../../lib/common.pl"; };
warn "$@" if $@;

my $solution1;
my $solution2;

my %tile_map =
  ( '.' => chr(0xb7),
    '#' => chr(0xf188), # 2593),
    'x' => chr(0x2299),
    '??' => chr(0x2573),
  );

my $data;
my $y = 0;
my $str = "";
while (<>) {
    chomp;
    my @row = split //;
    for my $x (0 .. @row-1) {
	my $tile = $row[$x];
	$data->{__map}{$y}{$x} = $tile;
	$data->{__fmap}{0}{$y}{$x} = $tile;
	$str .= $tile;
    }
    $y++;
}
$data->{__seen}{$str}++;

my $time = 0;
draw_map($data->{__map},0,0,4,4,$time);

while (1) {

    $time++;

    $data->{__old_map} = delete $data->{__map};
    my $str = "";
    for my $y (0 .. 4) {
	for my $x (0 .. 4) {
	    my $count;
	    $count++ if $data->{__old_map}{$y-1}{$x  } eq '#';
	    $count++ if $data->{__old_map}{$y  }{$x+1} eq '#';
	    $count++ if $data->{__old_map}{$y+1}{$x  } eq '#';
	    $count++ if $data->{__old_map}{$y  }{$x-1} eq '#';
	    my $tile = $data->{__old_map}{$y}{$x};
	    if ($tile eq '#') {
		$tile = '.' unless $count == 1;
	    }
	    else {
		$tile = '#' if $count == 1 || $count == 2;
	    }
	    $data->{__map}{$y}{$x} = $tile;
	    $str .= $tile;
	}
    }
    # printf "%s\n", $str;

    my $bio_rating = reverse $str;
    $bio_rating =~ tr/.#/01/;
    $bio_rating = oct("0b$bio_rating");
    $data->{__bio_rating} = $bio_rating;

    last if $data->{__seen}{$str}++;
}

draw_map($data->{__map},0,0,4,4,$time);

$solution1 = $data->{__bio_rating};

printf "Solution 1: %s\n", join " ", $solution1;

$time = 0;
$data->{__fmap}{0}{2}{2} = '?';
while (1) {

    # draw_fmap($data->{__fmap},0,0,4,4,$time);

    $time++;

    $data->{__old_fmap} = delete $data->{__fmap};
    my $str = "";
    my @levels = sort { $a <=> $b } keys %{$data->{__old_fmap}};
    my $min_level = $levels[0]-1;
    my $max_level = $levels[-1]+1;
    for my $level ($min_level .. $max_level) {
	my $modified = 0;
	# printf "t=%d, l=%d\n", $time, $level;
	for my $y (0 .. 4) {
	    for my $x (0 .. 4) {
		my $count;

		next if $x == 2 && $y == 2;

		# up
		if ($y-1 < 0) {
		    $count++ if $data->{__old_fmap}{$level-1}{1}{2} eq '#';
		}
		elsif ($x == 2 && $y-1 == 2) {
		    for my $ix (0..4) {
			$count++ if $data->{__old_fmap}{$level+1}{4}{$ix} eq '#';
		    }
		}
		else {
		    $count++ if $data->{__old_fmap}{$level}{$y-1}{$x} eq '#';
		}

		# right
		if ($x+1 > 4) {
		    $count++ if $data->{__old_fmap}{$level-1}{2}{3} eq '#';
		}
		elsif ($x+1 == 2 && $y == 2) {
		    for my $iy (0..4) {
			$count++ if $data->{__old_fmap}{$level+1}{$iy}{0} eq '#';
		    }
		}
		else {
		    $count++ if $data->{__old_fmap}{$level}{$y}{$x+1} eq '#';
		}

		# down
		if ($y+1 > 4) {
		    $count++ if $data->{__old_fmap}{$level-1}{3}{2} eq '#';
		}
		elsif ($x == 2 && $y+1 == 2) {
		    for my $ix (0..4) {
			$count++ if $data->{__old_fmap}{$level+1}{0}{$ix} eq '#';
		    }
		}
		else {
		    $count++ if $data->{__old_fmap}{$level}{$y+1}{$x} eq '#';
		}

		# left
		if ($x-1 < 0) {
		    $count++ if $data->{__old_fmap}{$level-1}{2}{1} eq '#';
		}
		elsif ($x-1 == 2 && $y == 2) {
		    for my $iy (0..4) {
			$count++ if $data->{__old_fmap}{$level+1}{$iy}{4} eq '#';
		    }
		}
		else {
		    $count++ if $data->{__old_fmap}{$level}{$y}{$x-1} eq '#';
		}

		my $tile = $data->{__old_fmap}{$level}{$y}{$x};
		if ($tile eq '#') {
		    $tile = '.' unless $count == 1;
		}
		else {
		    $tile = '#' if $count == 1 || $count == 2;
		}
		if (defined $tile) {
		    $data->{__fmap}{$level}{$y}{$x} = $tile;
		    $modified++;
		}
	    }
	}
	if ($modified) {
	    $data->{__fmap}{$level}{2}{2} = '?';
	}
    }

    last if $time >= 200;
}

# draw_fmap($data->{__fmap},0,0,4,4,$time);

$solution2 = 0;
for my $level (keys %{$data->{__fmap}}) {
    for my $y (0 .. 4) {
	for my $x (0 .. 4) {
	    $solution2++ if $data->{__fmap}{$level}{$y}{$x} eq '#';
	}
    }
}

printf "Solution 2: %s\n", join " ", $solution2;

exit;

sub draw_map {
    my($map,$min_x,$min_y,$max_x,$max_y,$info) = @_;
    # printf "\e[H";
    for my $y ($min_y-1 .. $max_y+1) {
	for my $x ($min_x-1 .. $max_x+1) {
	    my $color = 3;
	    my $tile = $map->{$y}{$x};
	    if ($tile eq '#') {
		$color = 202;
	    }
	    elsif ($tile eq '.') {
		$color = 15;
	    }
	    elsif ($tile eq '?') {
		$color = 1;
	    }
	    printf "\e[38;5;%sm%1s", $color, $tile_map{$tile || '??'} || $tile || '?';
	}
	printf "\e[m\e[K\n";
    }
    printf "info: %s\e[K\n", $info;
    printf "\e[J\n";
}

sub draw_fmap {
    my($map,$min_x,$min_y,$max_x,$max_y,$info) = @_;
    # printf "\e[H";
    for my $level (sort {$a <=> $b} keys %$map) {
	printf " %3d   ", $level;
    }
    print "\e[m\e[K\n";
    for my $y ($min_y .. $max_y) {
	for my $level (sort {$a <=> $b} keys %$map) {
	    for my $x ($min_x .. $max_x) {
		my $color = 3;
		my $tile = $map->{$level}{$y}{$x};
		if ($tile eq '#') {
		    $color = 202;
		}
		elsif ($tile eq '.') {
		    $color = 15;
		}
		elsif ($tile eq '?') {
		    $color = 1;
		}
		printf "\e[38;5;%sm%1s", $color, $tile_map{$tile || '??'} || $tile || '?';
	    }
	    print "  ";
	}
	printf "\e[m\e[K\n";
    }
    printf "info: %s\e[K\n", $info;
    printf "\e[J\n";
}
