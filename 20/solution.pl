#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my @particles;
while (<>) {
    chomp;
    my $p = { num => $.-1};
    while (s/^(.)=<(-?\d+),(-?\d+),(-?\d+)>,?\s*//) {
	$p->{$1} = [ $2, $3, $4 ];
    }
    push @particles, $p;
}

for my $iter (1 .. 1000) {
    my %pos_cache;
    for my $p (@particles) {
	next if $p->{dead};
	for (0..2) {
	    $p->{v}[$_] += $p->{a}[$_];
	    $p->{p}[$_] += $p->{v}[$_];
	}
	push @{$pos_cache{$p->{p}[0],$p->{p}[1],$p->{p}[2]}}, $p;
    }
    for my $pos (values %pos_cache) {
	next unless @$pos > 1;
	for my $p (@$pos) {
	    $p->{dead}++;
	    printf "Killing off %d, at %d,%d,%d in iteration %d\n",
	      $p->{num}, $p->{p}[0], $p->{p}[1], $p->{p}[2], $iter;
	}
    }
}

my $min_p = 0;
my $min_d =
  abs($particles[0]{p}[0])+
  abs($particles[0]{p}[1])+
  abs($particles[0]{p}[2]);

my $dead_count = $particles[0]{dead} ? 1 : 0;

for my $pn (1 .. @particles-1) {
    my $d =
      abs($particles[$pn]{p}[0])+
      abs($particles[$pn]{p}[1])+
      abs($particles[$pn]{p}[2]);
    if ($d < $min_d) {
	$min_d = $d;
	$min_p = $pn;
    }
    $dead_count++ if $particles[$pn]{dead};
}

printf "Solution 1: %d has %d\n", $min_p, $min_d;

printf "Solution 2: %d dead, %d left\n", $dead_count, @particles-$dead_count;
