#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my $input = do { $/ = undef; <>; };

for ($input) {
    s/!.//g;
    s/<[^>]*>//g;
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

printf "Solution: %d\n", $sum;
