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
    for my $o_index (0 .. @input-1) {
	my $pos = $o_index;
	my $output;
      POS:
	while (1) {
	    for (0..$o_index) {
		last POS unless $pos < @input;
		$output += $input[$pos++];
	    }
	    $pos += $o_index+1;
	    for (0..$o_index) {
		last POS unless $pos < @input;
		$output -= $input[$pos++];
	    }
	    $pos += $o_index+1;
	}
	push @output, abs($output)%10;
    }
    # printf "%s\n", join "", @output;
    @input = @output;
}

$solution1 = join "", @input[0..7];

printf "Solution 1: %s\n", join " ", $solution1;

# @input = @data x 10000

# 0p0n0p0n0p0n
#  ddd dddd dddd
# 0pp00nn00pp00nn

my @input = @data;
my $input_size = @data * 10000;

printf "Size: %s\n", $input_size;

for my $phase (1 .. 100) {
    my @output;
    for my $o_index (0 .. $input_size-1) {
	my $pos = $o_index;
	my $output = 0;
	my $m = lcm(0+@input,($o_index+1)*4);
	printf "i=%d: m=%s\n", $o_index, $m;
      POS:
	while (1) {
	    for (0..$o_index) {
		last POS unless $pos < $m;
		$output += $input[$pos++ % @input];
	    }
	    $pos += $o_index+1;
	    for (0..$o_index) {
		last POS unless $pos < $m;
		$output -= $input[$pos++ % @input];
	    }
	    $pos += $o_index+1;
	}
	push @output, abs($output)%10;
    }
    printf "%s\n", join "", @output;
    @input = @output;
}

my $offset = join "", @data[0..6];
for my $o ($offset .. $offset+6) {
    $solution2 .= $input[$o%@input];
}

printf "Solution 2: %s\n", join " ", $solution2;
