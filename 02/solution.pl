#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my $checksum = 0;
my $divsum = 0;
while (<>) {
    chomp;
    my @list = sort {$a <=> $b} split " ";
    $checksum += $list[-1]-$list[0];
  divsum:
    for my $i (0 .. @list-2) {
	for my $j ($i+1 .. @list-1) {
	    my $v = $list[$j]/$list[$i];
	    if ($v == int($v)) {
		$divsum += $v;
		last divsum;
	    }
	}
    }
}

printf "Solution 1: %d\n", $checksum;
printf "Solution 2: %d\n", $divsum;
