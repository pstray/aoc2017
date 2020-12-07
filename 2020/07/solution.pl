#! /usr/bin/perl
#
# Copyright (C) 2020 by Peder Stray <peder@ninja.no>
#

use strict;

use Data::Dumper;
use FindBin;
eval { require "$FindBin::Bin/../../lib/common.pl"; };

my $solution1 = 0;
my $solution2 = 0;

my %contained_in;
my %contains;
while (<>) {
    chomp;
    my $orig = $_;
    if (s/^(\S+ \S+) bags contain //) {
	my $container = $1;
	if (s/^no other bags\.//) {
	    # nothing to do
	}
	else {
	    while (s/^(\d+) (\S+ \S+) bags?[.,]\s*//) {
		$contained_in{$2}{$container} = $1;
		$contains{$container}{$2} = $1;
	    }
	}
    }
    if (length) {
	die "Error in input: $orig\n  left: $_\n";
    }
}

sub recurse1 {
    my($bag,$found) = @_;
    my @keys = keys %{$contained_in{$bag}};
    for my $key (@keys) {
	$found->{$key}++;
	recurse1($key,$found);
    }
}

my %found1;
recurse1("shiny gold",\%found1);
$solution1 = scalar keys %found1;

sub contains {
    my($bag) = @_;
    my $sum = 1;
    for my $b (keys %{$contains{$bag}}) {
	$sum += $contains{$bag}{$b} * contains($b);
    }
    return $sum;
}

$solution2 = contains("shiny gold")-1;

printf "Solution1: %s\n", $solution1;
printf "Solution2: %s\n", $solution2;
