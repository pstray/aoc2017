#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2020 by Peder Stray <peder@wintermute>
#

use strict;

my $solution1 = 0;
my $solution2 = 0;

$/ = "";
while (<>) {
    my $persons = scalar split "\n";
    y/a-z//cd;
    my %ans;
    for my $ans (split //) {
	$ans{$ans}++;
    }
    $solution1 += scalar keys %ans;
    $solution2 += scalar grep { $ans{$_} == $persons } keys %ans;
}

printf "Solution1: %s\n", $solution1;
printf "Solution2: %s\n", $solution2;
