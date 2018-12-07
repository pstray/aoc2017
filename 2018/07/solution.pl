#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

my %graph;
my %step;

while (<>) {
    chomp;
    if (/Step (.) must be finished before step (.) can begin\./) {
	$graph{$1}{$2}++;
	$step{$2}++;
	$step{$1} ||= 0;
    }
    else {
	printf "Unparsable: %s\n", $_;
    }
}

use Data::Dumper;

my %step1 = %step;

my %available = map { $_ => 1 } grep { $step{$_} == 0 } keys %step1;
my $order1 = "";
while (keys %available) {
    #print Dumper \%available;
    my($step) = sort keys %available;
    $order1 .= $step;
    delete $available{$step};
    for my $s (keys %{$graph{$step}}) {
	$available{$s}++ unless --$step1{$s};
    }
}

printf "Solution 1: %s (%d)\n", $order1, length $order1;

my %step2 = %step;
my $base = 60-ord("A")+1;
my $workers = 5;
my %available = map { $_ => $base+ord($_) } grep { $step{$_} == 0 } keys %step2;
my %running;

my @running;
my $order2 = "";

my(@steps) = sort {$a cmp $b} keys %available;

for my $step (@steps) {
    if (0+keys %running < $workers) {
	$running{$step} = delete $available{$step};
    }
}

my $time;
while (keys %running) {

#    print Dumper \%running;

    # printf "R: %d\n", 0+keys %running;

    my($first) = sort{$running{$a}<=>$running{$b}} keys %running;

    $time = delete $running{$first};
#    printf "T: %s at %d\n", $first, $time;
    
    $order2 .= $first;
    
    for my $s (keys %{$graph{$first}}) {
	unless (--$step2{$s}) {
	    $available{$s} = $base+ord($s);
	}
    }

#    print Dumper \%available;

    for my $step (sort keys %available) {
	last unless keys %running < $workers;
#	printf "Add: %s(%d) at %d = %d\n", $step, $available{$step}, $time,
	    $running{$step} = $time + delete $available{$step};
    }

}

printf "Solution 2: %s (%d) after %d\n", $order2, length $order2, $time;

