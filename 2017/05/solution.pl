#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my @jumps;

while (<>) {
    chomp;
    push @jumps, $_;
}

my @jumps2 = @jumps;

my $ip = 0;
my $cx = 0;

#printf "%s\n", join " ", map { $_==$ip ? "($jumps[$_])" : " $jumps[$_] " } 0 .. @jumps-1;
while ($ip < @jumps) {
    $cx++;
    $ip += $jumps[$ip]++;
#    printf "%s\n", join " ", map { $_==$ip ? "($jumps[$_])" : " $jumps[$_] " } 0 .. @jumps-1;
}

printf "Solution 1: %d jumps to escape\n", $cx;

$ip = $cx = 0;

#printf "%s\n", join " ", map { $_==$ip ? "($jumps2[$_])" : " $jumps2[$_] " } 0 .. @jumps2-1;
while ($ip < @jumps2) {
    $cx++;
    my $offset = $jumps2[$ip];
    if ($offset >= 3) {
	$jumps2[$ip]--;
    }
    else {
	$jumps2[$ip]++;
    }
    $ip += $offset;
    #printf "%s\n", join " ", map { $_==$ip ? "($jumps2[$_])" : " $jumps2[$_] " } 0 .. @jumps2-1;
}

printf "Solution 2: %d jumps to escape\n", $cx;
