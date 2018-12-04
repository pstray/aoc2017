#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

my %sleep;
my %minute;
my $guard;
my $time = 0;
my $date;
my $sleeping;

my @lines = sort <>;
my $line;

for (@lines) {

    chomp;
    if (my($y,$m,$d,$H,$M,$cmd) = /^\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] (.*)/) {
	if ($cmd =~ /^Guard #(\d+) begins shift/) {
	    warn "Last gard still sleeps\n" if $sleeping;
	    $sleeping = 0;
	    $guard = $1;
	    $time = 0;
	}
	elsif ($cmd eq "falls asleep") {
	    $time = $M;
	    $sleeping = 1;
	}
	elsif ($cmd eq "wakes up") {
	    if ($H > 0) {
		$M = 60;
	    }
	    for my $mm ($time .. $M-1 ) {
		$sleep{$guard}++;
		$minute{$guard}{$mm}++;
	    }
	    $sleeping = 0;
	}
	else {
	    die "Unknown cmd at $line: $cmd\n";
	}
    }
    else {
	warn "Unparsable input: $_\n";
    }
    $line++;
}

use Data::Dumper;

my($id) = sort { $sleep{$b} <=> $sleep{$a} } keys %sleep;

my($min) = sort { $minute{$id}{$b} <=> $minute{$id}{$a} } keys %{$minute{$id}};

printf "Solution 1: %d sleeps at %d: %d\n", $id, $min, $id * $min;

my($id2,$min2,$sleep2);
for my $g (sort {$a <=> $b} keys %minute) {
    my($m) = sort { $minute{$g}{$b} <=> $minute{$g}{$a} || $b <=> $a} keys %{$minute{$g}};
    my $s = $minute{$g}{$m};
    if ($s > $sleep2) {
	$sleep2 = $s;
	$min2 = $m;
	$id2 = $g;
    }
}

printf "Solution 2: %d sleeps most at %d: %d\n", $id2, $min2, $id2 * $min2;
