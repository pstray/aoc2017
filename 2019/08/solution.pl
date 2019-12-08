#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;
use open ':locale';

use Data::Dumper;

$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

my $solution1;
my $solution2;

my $width = 25;
my $height = 6;
my $layer_size = $width * $height;

my $data;

while (<>) {
    chomp;
    $data .= $_;
}

my @layers;
my $pos = 0;
my $data_size = length $data;

if ($data_size % $layer_size) {
    die "Wrong input size!\n";
}

while ($pos < $data_size) {
    push @layers, substr $data, $pos, $layer_size;
    $pos += $layer_size;
}

my $min_0 = $layer_size;
for my $layer (@layers) {
    my $count_zero;
    $count_zero = $layer =~ y/0//;

    if ($count_zero < $min_0) {
	printf "found %d\n", $count_zero;
	$min_0 = $count_zero;
	$solution1 = ($layer =~ y/1//) * ($layer =~ y/2//);
    }
}

printf "Solution 1: %s\n", $solution1;

my @image = (2) x $layer_size;
for my $layer (reverse @layers) {
    my @l = split //, $layer;
    for my $i (0 .. @l-1) {
	next if $l[$i] == 2;
	$image[$i] = $l[$i];
    }
}

printf "Solution 2: %s\n", $solution2;
for my $i (0 .. $layer_size-1) {
    printf "\n" unless $i % $width;
    my $p = $image[$i];
    if ($p == 0) {
	printf " ";
    }
    elsif ($p == 1) {
	printf "\x{2588}";
    }
    else {
	printf ".";
    }
}
printf "\n";
