#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my @msg;
while (<>) {
    chomp;
    my @chars = split //;
    for my $i (0 .. @chars-1) {
	$msg[$i]{$chars[$i]}++;
    }
}

my $ans1 = "";
my $ans2 = "";
for my $cc (@msg) {
    my($c1) = sort{$cc->{$b}<=>$cc->{$a} || $a cmp $b } keys %$cc;
    my($c2) = sort{$cc->{$a}<=>$cc->{$b} || $a cmp $b } keys %$cc;
    $ans1 .= $c1;
    $ans2 .= $c2;
}

printf "Solution 1: Message is [%s]\n", $ans1;
printf "Solution 2: Message is [%s]\n", $ans2;
