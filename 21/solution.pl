#! /usr/bin/perl

use strict;

use Data::Dumper;

@ARGV = qw(input) unless @ARGV;

my @art = (".#./..#/###");
my $size = 3;

my %rules2;
my %rules3;

while (<>) {
    chomp;
    if (my @rule = m,^(.)(.)/(.)(.) => (.../.../...)$,) {
	$rules2{sprintf "%s%s/%s%s", @rule[qw(0 1 2 3)]} = $rule[4];
	$rules2{sprintf "%s%s/%s%s", @rule[qw(1 0 3 2)]} = $rule[4];
	$rules2{sprintf "%s%s/%s%s", @rule[qw(1 2 3 0)]} = $rule[4];
	$rules2{sprintf "%s%s/%s%s", @rule[qw(2 3 0 1)]} = $rule[4];
	$rules2{sprintf "%s%s/%s%s", @rule[qw(3 0 1 2)]} = $rule[4];
    }
    elsif (my @rule = m,^(.)(.)(.)/(.)(.)(.)/(.)(.)(.) => (..)(..)/(..)(..)/(..)(..)/(..)(..)$,) {
	my $blocks =
	  [
	   map { sprintf "%s/%s", @rule[@$_] }
	   [ 9, 11 ], [ 10, 12 ], [ 13, 15 ], [ 14, 16 ]
	  ];

	# 0 1 2
	# 3 4 5
	# 6 7 8

	$rules2{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(0 1 2 3 4 5 6 7 8)]} = $blocks;
	$rules2{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(2 5 8 1 4 7 0 3 6)]} = $blocks;
	$rules2{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(8 7 6 5 4 3 2 1 0)]} = $blocks;
	$rules2{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(6 3 0 7 4 1 8 5 2)]} = $blocks;
	$rules2{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(2 1 0 5 4 3 8 7 6)]} = $blocks;
	$rules2{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(6 7 8 2 4 5 0 1 2)]} = $blocks;
	
    }
    else {
	die "unhandled rule [$_]\n";
    }
    
}

while (1) {
    if ($size % 2 == 0) {
	



	$size *= 3/2;
    }
    elsif ($size % 3 == 0) {
	my @new;
	for my $i (0 .. @art-1) {
	    
	}


	$size *= 4/3;
    }

    printf "%d\n", $size;
    sleep 1;
}
