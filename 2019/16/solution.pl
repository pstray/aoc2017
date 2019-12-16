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

my @data;
my @in_pattern = (0, 1, 0, -1);

while (<>) {
    chomp;
    if (/(\d+)/) {
	@data = split //, $1;
	last;
    }
    else {
	die "Kablam! $_\n";
    }
}

my @input = @data;
for my $phase (1 .. 100) {
    my @output;
    for my $mult (1 .. @input) {
	my @pattern;
	for my $in (@in_pattern) {
	    push @pattern, ($in) x $mult;
	    last if @pattern > @input;
	}
	my $output;
	for my $i (0 .. @input-1) {
	    $output += $input[$i] * $pattern[($i+1) % @pattern];
	}
	push @output, abs($output)%10;
    }
    printf "%s\n", join "", @output;
    @input = @output;
}

$solution1 = join "", @input[0..7];

printf "Solution 1: %s\n", join " ", $solution1;
printf "Solution 2: %s\n", join " ", $solution2;
