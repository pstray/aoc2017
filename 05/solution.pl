#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my @jumps;

while (<>) {
    chomp;
    push @jumps, $_;
}

my $ip = 0;
my $cx = 0;

#printf "%s\n", join " ", map { $_==$ip ? "($jumps[$_])" : " $jumps[$_] " } 0 .. @jumps-1;
while ($ip < @jumps) {
    $cx++;
    $ip += $jumps[$ip]++;
#    printf "%s\n", join " ", map { $_==$ip ? "($jumps[$_])" : " $jumps[$_] " } 0 .. @jumps-1;
}

printf "Solution 1: %d jumps to escape\n", $cx;

