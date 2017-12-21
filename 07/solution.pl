#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my %prog;

while (<>) {
    chomp;
    if (my($prog,$weight,$kids) = m,^(\S+)\s+\((\d+)\)(?:\s*->\s+(.*))?,) {
	my @kids = split /\s*,\s*/, $kids;
	$prog{$prog}{w} = $weight;
	for my $kid (@kids) {
	    $prog{$kid}{kid}++;
	}
    }
    else {
	die "unhandled input [$_]\n";
    }
}

my($top,@others) = grep { !$prog{$_}{kid} } keys %prog;

printf "Solution 1: top = '%s'\n", $top;
if (@others) {
    printf "  ... but i found others: %s\n", join ", ", @others;
}
