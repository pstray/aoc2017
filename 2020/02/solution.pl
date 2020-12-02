#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2020 by Peder Stray <peder@wintermute>
#

use strict;

my $solution1 = 0;
my $solution2 = 0;

while (<>) {
    if (my($low,$high,$char,$pass) = /(\d+)-(\d+)\s+(\S):\s+(\S+)/) {
	my $test = $pass;
	my($count) = $test =~ s/$char/./g;
	if ($count >= $low && $count <= $high) {
	    $solution1++;
	}
	if (substr($pass,$low-1,1) eq $char ^
	    substr($pass,$high-1,1) eq $char) {
	    $solution2++;
	}
    }
}

printf "Solution 1: %d\n", $solution1;
printf "Solution 2: %d\n", $solution2;
