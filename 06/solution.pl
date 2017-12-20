#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my @banks = split " ", do { local $/ = undef; <> };

my %seen;
$seen{"@banks"} = 1;
my $cycles = 0;

while (1) {
    # print "@banks";
    $cycles++;
    my($max) = sort {$b<=>$a} @banks;
    my($pos) = grep { $banks[$_] == $max } 0 .. @banks-1;
    my $val = $banks[$pos];
    # printf " == $max $pos $val";
    $banks[$pos] = 0;
    while ($val-->0) {
	$banks[++$pos%@banks]++;
    }
    # printf "\n";
    last if $seen{"@banks"}++;
}

printf "Solution 1: %d cycles\n", $cycles;
