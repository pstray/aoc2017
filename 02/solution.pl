#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my $checksum = 0;
while (<>) {
    chomp;
    my @list = sort {$a <=> $b} split " ";
    $checksum += $list[-1]-$list[0];
}

printf "Solution 1: %d\n", $checksum;
