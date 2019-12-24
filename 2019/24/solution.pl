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
    printf "%s\n", $str;

    my $bio_rating = reverse $str;
    $bio_rating =~ tr/.#/01/;
    $bio_rating = oct("0b$bio_rating");
    $data->{__bio_rating} = $bio_rating;

    last if $data->{__seen}{$str}++;
}

draw_map($data->{__map},0,0,4,4,$time);

$solution1 = $data->{__bio_rating};

printf "Solution 1: %s\n", join " ", $solution1;


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

