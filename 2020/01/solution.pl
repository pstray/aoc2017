#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2020 by Peder Stray <peder@wintermute>
#

use strict;

my @list;
while (<>) {
    chomp;
    push @list, split " ", $_;
}

@list = sort {$a <=> $b} @list;

my($n1,$n2,$sum);
my $count = 0;

for my $i (0 .. @list-2) {
    $n1 = $list[$i];
    for my $j ($i+1 .. @list-1) {
	$n2 = $list[$j];
	$sum = $n1+$n2;
	$count++;
	last if $sum >= 2020;
    }
    last if $sum == 2020;
}

printf("n1: %d  n2: %d  sum: %d  count: %d  prod: %d\n",
       $n1, $n2, $sum, $count,
       $n1*$n2,
      );

my $n3;

$count = 0;
for my $i (0 .. @list-3) {
    $n1 = $list[$i];
    for my $j ($i+1 .. @list-2) {
	$n2 = $list[$j];
	$sum = $n1+$n2;
	last if $sum >= 2020;
	for my $k ($j+1 .. @list-1) {
	    $n3 = $list[$k];
	    $sum = $n1+$n2+$n3;
	    $count++;
	    last if $sum >= 2020;
	}
	last if $sum == 2020;
    }
    last if $sum == 2020;
}

printf("n1: %d  n2: %d  n3: %d  sum: %d  count: %d  prod: %d\n",
       $n1, $n2, $n3, $sum, $count,
       $n1*$n2*$n3,
      );
