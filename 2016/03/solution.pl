#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my $ans1 = 0;
my $ans2 = 0;

my @cache;
while (<>) {
    chomp;
    my @line = split " ";
    my($aa,$bb,$cc) = sort{$a<=>$b} @line;
    $ans1++ if $aa+$bb > $cc;

    push @cache, [@line];
    if (@cache == 3) {
	my($aa1, $bb1, $cc1) = sort {$a<=>$b} map { $cache[$_][0] } 0..2;
	my($aa2, $bb2, $cc2) = sort {$a<=>$b} map { $cache[$_][1] } 0..2;
	my($aa3, $bb3, $cc3) = sort {$a<=>$b} map { $cache[$_][2] } 0..2;

	# printf "%d %d %d\n", $aa1, $bb1, $cc1;
	# printf "%d %d %d\n", $aa2, $bb2, $cc2;
	# printf "%d %d %d\n", $aa3, $bb3, $cc3;
	
	$ans2++ if $aa1+$bb1 > $cc1;
	$ans2++ if $aa2+$bb2 > $cc2;
	$ans2++ if $aa3+$bb3 > $cc3;

	@cache = ();
    }
}

die "wtf Cache" if @cache;

printf "Solution 1: %d possible triangles found\n", $ans1;
printf "Solution 2: %d possible vertical triangles found\n", $ans2;
