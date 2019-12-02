#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;

my $solution1;
my $solution2;

my @code;

while (<>) {
    chomp;
    push @code, grep { /^\d+$/ } split /,/;
}
#print "c1: @code\n";

$solution1 = runcode(12, 2, @code);

printf "Solution 1: %s\n", $solution1;

my $max_n = 99;
my $max_v = 99;
for my $noun (0 .. $max_n) {
    for my $verb (0 .. $max_v) {
	my $s = $noun * 100 + $verb;
	my $r = runcode($noun, $verb, @code);
	if ($r == 19690720) {
	    # printf "%2d %2d = %d\n", $noun, $verb, $r;
	    $solution2 = $s
	}
    }
}
printf "Solution 2: %s\n", $solution2;

sub runcode {
    my($noun,$verb,@mem) = @_;
    my $ip = 0;
    $mem[1] = $noun;
    $mem[2] = $verb;

    while (1) {
	my $op = $mem[$ip++];
	if ($op == 1) {
	    my $a1 = $mem[$ip++];
	    my $a2 = $mem[$ip++];
	    my $a3 = $mem[$ip++];
	    #printf "$a3 = $a1 + $a2\n";
	    $mem[$a3] = $mem[$a1] + $mem[$a2];
	}
	elsif ($op == 2) {
	    my $a1 = $mem[$ip++];
	    my $a2 = $mem[$ip++];
	    my $a3 = $mem[$ip++];
	    #printf "$a3 = $a1 * $a2\n";
	    $mem[$a3] = $mem[$a1] * $mem[$a2];
	}
	elsif ($op == 99) {
	    last;
	}
	else {
	    warn "Kablam! op = $op\n";
	    return;
	}
    }
    return $mem[0];
}
