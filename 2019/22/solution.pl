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

my @seq;

while (<>) {
    chomp;
    if (/^deal with increment (\d+)/) {
	push @seq, [ inc => $1 ];
    }
    elsif (/^cut ([-\d]+)/) {
	push @seq, [ cut => $1 ];
    }
    elsif (/^deal into new stack/) {
	push @seq, [ 'new' ];
    }
    else {
	die "Kablam! Unknown input: $_\n";
    }
}

# my $cards = 10;
# my @deck = (0 .. $cards-1);
# for my $s (@seq) {
#     my($what,$param) = @$s;
#     if ($what eq 'new') {
#	@deck = reverse @deck;
#     }
#     elsif ($what eq 'cut') {
#	if ($param > 0) {
#	    push @deck, splice @deck, 0, $param;
#	}
#	else {
#	    unshift @deck, splice @deck, $param;
#	}
#     }
#     elsif ($what eq 'inc') {
#	my @new;
#	my $i = 0;
#	for my $card (@deck) {
#	    $new[$i] = $card;
#	    $i += $param;
#	    $i = $i % @deck;
#	}
#	@deck = @new;
#     }
#     else {
#	die "Kablam! unknown '$what'\n";
#     }
# }

# $solution1 = join " ", grep { $deck[$_] == 2019 } 0..$cards-1;

my $cards = 10007;
my $pos = 2019;
for my $s (@seq) {
    my($what,$param) = @$s;
    if ($what eq 'new') {
	$pos = $cards-1-$pos;
    }
    elsif ($what eq 'cut') {
	$pos -= $param;
	$pos %= $cards;
    }
    elsif ($what eq 'inc') {
	$pos = $pos * $param;
	$pos %= $cards;
    }
}

$solution1 = $pos;

printf "Solution 1: %s\n", join " ", $solution1;






printf "Solution 2: %s\n", join " ", $solution2;
