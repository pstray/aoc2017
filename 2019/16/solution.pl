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

my @input = (@data) x 10000;
my $input_size = @input;
my $offset = join "", @data[0..6];

# For any index over halfway, n-1 is the sum of the previous n and n-1,
# but for any index lower, it gets more complex... thus:
#
#  0 +_-_+_-_+_-_+_-_|+_-_+_-_+_-_+_-_|+_-_+_-_+_-_+_-_|+_-_+_-_+_-_+_-_|
#  1 _++__--__++__--_|_++__--__++__--_|_++__--__++__--_|_++__--__++__--_|
#  2 __+++___---___++|+___---___+++___|---___+++___---_|__+++___---___++|
#  3 ___++++____----_|___++++____----_|___++++____----_|___++++____----_|
#  4 ____+++++_____--|---_____+++++___|__-----_____++++|+_____-----_____|
#  5 _____++++++_____|_------______+++|+++______------_|_____++++++_____|
#  6 ______+++++++___|____-------_____|__+++++++_______|-------_______++|
#  7 _______++++++++_|_______--------_|_______++++++++_|_______--------_|
#  8 ________++++++++|+_________------|---_________++++|+++++_________--|
#  9 _________+++++++|+++__________---|-------_________|_++++++++++_____|
# 10 __________++++++|+++++___________|-----------_____|______++++++++++|
# 11 ___________+++++|+++++++_________|___------------_|___________+++++|
# 12 ____________++++|+++++++++_______|______----------|---_____________|
# 13 _____________+++|+++++++++++_____|_________-------|-------_________|
# 14 ______________++|+++++++++++++___|____________----|-----------_____|
# 15 _______________+|+++++++++++++++_|_______________-|---------------_|

die sprintf "Only valid for %s >= %s\n", $offset, $input_size/2
  if $offset < $input_size/2;

splice @input, 0, $offset;
for my $phase (1 .. 100) {
    # go from the end, so we dont overwrite a previous value we need
    for (my $i = @input-1; $i > 0; $i--) {
	$input[$i-1] = ($input[$i-1]+$input[$i]) % 10;
    }
}

$solution2 = join "", @input[0..7];

printf "Solution 2: %s\n", join " ", $solution2;
