#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;
use open ':locale';

use POSIX qw(ceil);

use Data::Dumper;

eval { require "../../lib/common.pl"; };
warn "$@" if $@;

$Data::Dumper::Sort = 1;

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
	if ($tile eq '@') {
	    $data->{__start_x} = $x;
	    $data->{__start_y} = $y;
	    $tile = '.';
	}
	elsif ($tile =~ /[a-z]/) {
	    $data->{__key}{$tile} = [ $x, $y ];
	}
	elsif ($tile =~ /[A-Z]/) {
	    $data->{__door}{$tile} = [ $x, $y ];
	}
	$data->{__map}{$y}{$x} = $tile;

    }
    $data->{__max_y} = $y;
    $data->{__max_x} = @row-1 if @row-1 > $data->{__max_x};
    $y++;
}

my %tile_map =
  ( '.' => chr(0xb7),
    '#' => chr(0x2593),
    '?' => chr(0x2573),
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
	    if ($self->{__check}{"$x,$y"}) {
		$color = 5;
	    }
	    elsif ($tile eq '#') {
		$color = 202;
	    }
	    elsif ($tile eq '.') {
		my $v = $self->{__visit}{$y}{$x};
		$color = 255 - $v;
		$color = 1 if $color < 232;
	    }
	    elsif ($self->{__check}{"$x,$y"}) {
		$color = 5;
	    }
	    printf "\e[38;5;%sm%1s", $color, $tile_map{$tile || '?'} || $tile || '?';
	}
	printf "\e[m\e[K\n";
    }
    printf "info: %s\e[K\n", $info;
    printf "\e[J";

}

# draw_map($data);

sub find_keys {
    my($map,$sx,$sy) = @_;
    my @pos = ( [ 0+$sx, 0+$sy ] );
    my %keys;
    my $depth = 0;
    my %depth;
    while (@pos) {
	my @n_pos;
	# printf "D=%s:", $depth;
	for my $p (@pos) {
	    my($x,$y) = @$p;
	    # printf " %d,%d", $x,$y;

	    $depth{$y}{$x} = $depth;
	    if ($map->{__map}{$y}{$x} =~ /[a-z]/) {
		my $k = $map->{__map}{$y}{$x};
		if (exists $keys{$k}) {
		    $keys{$k}{d} = $depth if $keys{$k}{d} > $depth;
		}
		else {
		    $keys{$k}{d} = $depth;
		}
		$keys{$k}{data} = [ $x, $y, $k, $depth ];
	    }
	    elsif ($map->{__map}{$y}{$x} =~ /[A-Z]/) {
		# cant pass...
	    }
	    else {
		if (!exists $depth{$y-1}{$x} && $map->{__map}{$y-1}{$x} ne '#') {
		    push @n_pos, [ $x, $y-1 ];
		}
		if (!exists $depth{$y}{$x+1} && $map->{__map}{$y}{$x+1} ne '#') {
		    push @n_pos, [ $x+1, $y ];
		}
		if (!exists $depth{$y+1}{$x} && $map->{__map}{$y+1}{$x} ne '#') {
		    push @n_pos, [ $x, $y+1 ];
		}
		if (!exists $depth{$y}{$x-1} && $map->{__map}{$y}{$x-1} ne '#') {
		    push @n_pos, [ $x-1, $y ];
		}
	    }
	}
	# printf "\n";
	$depth++;
	@pos = @n_pos;
    }
    return map { $keys{$_}{data} } keys %keys;
}

my %solved;

sub solve {
    my($data,$sx,$sy,$lev,@opened) = @_;

    my @keys = find_keys($data, $sx, $sy);

    @keys = sort { $a->[3] <=> $b->[3] ||
		     $a->[2] cmp $b->[2] } @keys;

    my $state = join ",", $sx, $sy, map({ $_->[2] } @keys),
      #sort(@opened),
      ;

    if ($solved{$state}) {
	# printf "seen $state!\n";
	return $solved{$state};
    }

    unless (@keys) {
	printf "one $lev!\n";
	return 0;
    }

    printf "%sK: %s\n", " "x$lev, join ", ", map { $_->[2].'='.$_->[3] } @keys;

    my @steps;

    for my $k (@keys) {
	my($x,$y,$key,$depth) = @$k;
	my $door = uc $key;
	my $dd = $data->{__door}{$door};
	my($dx,$dy) = $dd ? @$dd : ($x,$y);

	# mark the door and current position as empty
	local $data->{__map}{$y}{$x} = '.';
	local $data->{__map}{$dy}{$dx} = '.';

	# draw_map($data);
	my $steps = $depth+solve($data, $x, $y, $lev+1, @opened, $door);
	push @steps, $steps;
    }

    my ($best) = sort { $a <=> $b } @steps;

    $solved{$state} = $best;
    # printf "%s = %d\n", " "x$lev, $best;

    return $best;
}

$solution1 = solve($data, $data->{__start_x}, $data->{__start_y});



printf "Solution 1: %s\n", join " ", $solution1;
printf "Solution 2: %s\n", join " ", $solution2;
