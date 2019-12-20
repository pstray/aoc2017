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

my $data;
my $y = 0;
$data->{__min_x} = 0;
$data->{__min_y} = 0;
$data->{__max_x} = 0;
$data->{__max_y} = 0;
while (<>) {
    chomp;
    my @row = split //;
    for my $x (0 .. @row-1) {
	my $tile = $row[$x];
	next if $tile eq ' ';
	$data->{__map}{$y}{$x} = $tile;
    }
    $data->{__max_y} = $y;
    $data->{__max_x} = @row-1 if @row-1 > $data->{__max_x};
    $y++;
}

$data->{__min_wall_x} = $data->{__max_x};
$data->{__min_wall_y} = $data->{__max_y};
$data->{__max_wall_x} = $data->{__min_x};
$data->{__max_wall_y} = $data->{__min_y};

for my $y (keys %{$data->{__map}}) {
    for my $x (keys %{$data->{__map}{$y}}) {
	if ($data->{__map}{$y}{$x} eq '#') {
	    $data->{__max_wall_x} = $x if $data->{__max_wall_x} < $x;
	    $data->{__max_wall_y} = $y if $data->{__max_wall_y} < $y;
	    $data->{__min_wall_x} = $x if $data->{__min_wall_x} > $x;
	    $data->{__min_wall_y} = $y if $data->{__min_wall_y} > $y;
	}
    }
}

sub inside {
    my($self,$x,$y) = @_;
    return 0 if $x < $self->{__min_wall_x};
    return 0 if $y < $self->{__min_wall_y};
    return 0 if $x > $self->{__max_wall_x};
    return 0 if $y > $self->{__max_wall_y};
    return 1;
}

for my $y (sort { $a <=> $b } keys %{$data->{__map}}) {
    for my $x (sort { $a <=> $b } keys %{$data->{__map}{$y}}) {
	my $tile =  $data->{__map}{$y}{$x};
	if ($tile eq '.') {
	    # UP
	    if ($data->{__map}{$y-1}{$x} =~ /[A-Z]/) {
		my @p = ($data->{__map}{$y-1}{$x}, $data->{__map}{$y-2}{$x});
		my $i = inside($data,$x,$y-1);
		my $p = join "", sort @p;
		$data->{__portal}{$p}[$i] = [ $x, $y, $i ];
	    }
	    # RIGHT
	    if ($data->{__map}{$y}{$x+1} =~ /[A-Z]/) {
		my @p = ($data->{__map}{$y}{$x+1}, $data->{__map}{$y}{$x+2});
		my $i = inside($data,$x+1,$y);
		my $p = join "", sort @p;
		$data->{__portal}{$p}[$i] = [ $x, $y, $i ];
	    }
	    # DOWN
	    if ($data->{__map}{$y+1}{$x} =~ /[A-Z]/) {
		my @p = ($data->{__map}{$y+1}{$x}, $data->{__map}{$y+2}{$x});
		my $i = inside($data,$x,$y+1);
		my $p = join "", sort @p;
		$data->{__portal}{$p}[$i] = [ $x, $y, $i ];
	    }
	    # LEFT
	    if ($data->{__map}{$y}{$x-1} =~ /[A-Z]/) {
		my @p = ($data->{__map}{$y}{$x-1}, $data->{__map}{$y}{$x-2});
		my $i = inside($data,$x-1,$y);
		my $p = join "", sort @p;
		$data->{__portal}{$p}[$i] = [ $x, $y, $i ];
	    }
	}
    }
}

# print Dumper $data->{__portal};

my %tile_map =
  ( '.' => chr(0xb7),
    '#' => chr(0x2593),
    '?' => chr(0x2573),
    'x' => chr(0x2299),
  );

sub draw_map {
    my($self,$info) = @_;
    printf "\e[H";
    my $min_y = 0+$self->{__min_y};
    my $max_y = 0+$self->{__max_y};
    my $min_x = 0+$self->{__min_x};
    my $max_x = 0+$self->{__max_x};
    printf "MAP (%d,%d) (%d,%d)\e[K\n", $min_x, $min_y, $max_x, $max_y;
    for my $y ($min_y-1 .. $max_y+1) {
	for my $x ($min_x-1 .. $max_x+1) {
	    my $color = 3;
	    my $tile = $self->{__map}{$y}{$x};
	    if ($tile eq '#') {
		$color = 202;
	    }
	    elsif ($tile eq '.') {
		$color = 15;
		if ($self->{__depth}{$y}{$x}) {
		    $tile = 'x';
		    $color = 4;
		}
	    }
	    elsif ($tile =~ /[A-Z]/) {
		$color = 5;
	    }
	    printf "\e[38;5;%sm%1s", $color, $tile_map{$tile || '?'} || $tile || '?';
	}
	printf "\e[m\e[K\n";
    }
    printf "info: %s\e[K\n", $info;
    printf "\e[J\n";
}

# draw_map($data);

sub next_pos {
    my($x,$y,$d) = @_;
    if ($d == 0) { # up
	$y--;
    }
    elsif ($d == 1) { # right
	$x++;
    }
    elsif ($d == 2) { # down
	$y++;
    }
    elsif ($d == 3) { # left
	$x--;
    }
    return ($x,$y);
}

my @explore = ($data->{__portal}{ZZ}[0]);
my $depth = 0;

EXPLORE1:
while (@explore) {
    my @next;
    # draw_map($data, "$depth ".join " ", map { $_->[0].",".$_->[1] } @explore);
    for my $pos (@explore) {
	my($x,$y) = @$pos;
	next if $data->{__depth}{$y}{$x};
	$data->{__depth}{$y}{$x} = $depth;

	for my $dir (0..3) {
	    my($nx,$ny) = next_pos($x,$y,$dir);
	    my $tile = $data->{__map}{$ny}{$nx};
	    if ($tile eq '.') {
		# ok
	    }
	    elsif ($tile =~ /[A-Z]/) {
		my($px,$py) = next_pos($nx,$ny,$dir);
		my $p_name = join "", sort $tile, $data->{__map}{$py}{$px};
		last EXPLORE1 if $p_name eq 'AA';
		my $p = $data->{__portal}{$p_name};
		my($np) = grep { $_->[0] != $x || $_->[1] != $y } @$p;
		if ($np) {
		    $nx = $np->[0];
		    $ny = $np->[1];
		}
	    }
	    else {
		next;
	    }
	    next if $data->{__depth}{$ny}{$nx};
	    push @next, [ $nx, $ny ];
	}
    }
    @explore = @next;
    $depth++;
    # sleep .1;
}

# draw_map($data, "done");

my($ex,$ey) = @{$data->{__portal}{AA}[0]};
$solution1 = $data->{__depth}{$ey}{$ex};

printf "Solution 1: %s\n", join " ", $solution1;

my @explore = ( map { [ @$_, 0 ] } $data->{__portal}{ZZ}[0]);
my $steps = 0;
my $max_level = 0;
EXPLORE2:
while (@explore) {
    my @next;
    # printf "step: %d\n", $steps;
    # draw_map($data, "$depth ".join " ", map { $_->[0].",".$_->[1] } @explore);
    for my $pos (@explore) {
	my($x,$y,$level) = @$pos;
	$max_level = $level if $level > $max_level;
	next if $data->{__steps}[$level]{$y}{$x};
	$data->{__steps}[$level]{$y}{$x} = $steps;
	# print "  exploring $x,$y,$level\n";

	for my $dir (0..3) {
	    my($nx,$ny) = next_pos($x,$y,$dir);
	    my $nl = $level;
	    my $tile = $data->{__map}{$ny}{$nx};
	    if ($tile eq '.') {
		# ok
	    }
	    elsif ($tile =~ /[A-Z]/) {
		my($px,$py) = next_pos($nx,$ny,$dir);
		my $p_name = join "", sort $tile, $data->{__map}{$py}{$px};

		if ($p_name eq 'ZZ') {
		    # printf "    Portal ZZ... skipping\n";
		    next;
		}
		if ($p_name eq 'AA') {
		    last EXPLORE2 unless $level;
		    next;
		}

		my $p = $data->{__portal}{$p_name};

		# printf "    Portal (%s)\n", $p_name;
		my($np) = grep { $_->[0] != $x || $_->[1] != $y } @$p;
		my($np_x,$np_y,$np_i) = @$np;

		if ($level == 0 && $np_i) {
		    next; # outer level ending up at inner? = wall
		}

		$nx = $np_x;
		$ny = $np_y;
		$nl = $np_i ? $level-1 : $level+1;

		# printf "      move to: %d,%d,%d\n", $nx, $ny, $nl;
	    }
	    else {
		next;
	    }
	    next if $data->{__steps}[$nl]{$ny}{$nx};
	    # printf "    Adding: %d,%d,%d\n", $nx, $ny, $nl;
	    push @next, [ $nx, $ny, $nl ];
	}
    }
    @explore = @next;
    $steps++;
    # sleep .1;
}

my($ex,$ey) = @{$data->{__portal}{AA}[0]};
$solution2 = $data->{__steps}[0]{$ey}{$ex} || 'no path';

printf "Solution 2: %s\n", join " ", $solution2, $max_level;
