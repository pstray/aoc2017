#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my $input = do { local $/ = undef; <>; };
chomp $input;
my @lengths = split ",", $input;

sub knot_hash_1 {
    my @lengths = @_;
    my @list = (0 .. 255);
    my $pos = 0;
    my $skip = 0;

    for my $length (@lengths) {
	push @list, splice @list, 0, $pos;
	splice @list, 0, $length, reverse @list[0 .. $length-1];
	unshift @list, splice @list, -$pos;

	$pos += $length + $skip;
	$pos %= 0+@list;
	$skip++;
    }
    return @list;
}

die "invalid length detected\n"
  if grep { $_ > 255 } @lengths;

my @list = knot_hash_1(@lengths);

printf "Solution 1: %d\n", $list[0]*$list[1];

sub knot_hash {
    my($input) = @_;
    my @input = unpack "c*", $input;
    my @sparse_hash = (0 .. 255);
    my $pos = 0;
    my $skip = 0;

    push @input, 17, 31, 73, 47, 23;

    for my $round (1 .. 64) {
	for my $length (@input) {
	    push @sparse_hash, splice @sparse_hash, 0, $pos;
	    splice @sparse_hash, 0, $length, reverse @sparse_hash[0 .. $length-1];
	    unshift @sparse_hash, splice @sparse_hash, -$pos;
	    $pos += $length + $skip;
	    $pos %= 256;
	    $skip++;
	}
    }

    my @dense_hash;
    for my $i (0 .. 255) {
	push @dense_hash, 0 unless $i % 16;
	$dense_hash[-1] ^= $sparse_hash[$i];
    }

    return unpack "H*", pack "c*", @dense_hash;
}

for my $test ("", "AoC 2017", "1,2,3", "1,2,4") {
    printf "%-10s: %s\n", "'$test'", knot_hash($test);
}

printf "Solution 2: %s\n", knot_hash($input);
