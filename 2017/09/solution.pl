#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my $input = do { local $/ = undef; <>; };

my $garbage = 0;
for ($input) {
    s/!.//g;
    s/<([^>]*)>/$garbage += length $1;""/ge;
}

my $sum = 0;
my $level = 0;
for (split //, $input) {
    if (/\{/) {
	$level++;
    }
    elsif (/\}/) {
	$sum += $level;
	$level--;
    }
}
if ($level) {
    die "Not balanced! $level off\n";
}

printf "Part 1: %d\n", $sum;
printf "Part 2: %d\n", $garbage;
