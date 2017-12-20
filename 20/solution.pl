#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my @particles;
while (<>) {
    chomp;
    my $p = {};
    while (s/^(.)=<(-?\d+),(-?\d+),(-?\d+)>,?\s*//) {
	$p->{$1} = [ $2, $3, $4 ];
    }
    push @particles, $p;
}

for my $iter (1 .. 1000) {
    for my $p (@particles) {
	for (0..2) {
	    $p->{v}[$_] += $p->{a}[$_];
	    $p->{p}[$_] += $p->{v}[$_];
	}
    }
}

my $min_p = 0;
my $min_d =
  abs($particles[0]{p}[0])+
  abs($particles[0]{p}[1])+
  abs($particles[0]{p}[2]);

for my $pn (1 .. @particles-1) {
    my $d =
      abs($particles[$pn]{p}[0])+
      abs($particles[$pn]{p}[1])+
      abs($particles[$pn]{p}[2]);
    if ($d < $min_d) {
	$min_d = $d;
	$min_p = $pn;
    }    
}

use Data::Dumper;

print Dumper $particles[0];

printf "Solution 1: %d has %d\n", $min_p, $min_d;
