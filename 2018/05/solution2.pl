#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

my $data = do { local $/ = undef; <> };
chomp $data;

my @data = map { ord } split //, $data;

while (1) {
    my $length = @data;
    my $i = 0;
    while ($i < @data) {
	if (($data[$i] ^ $data[$i+1]) == 32) {
	    splice @data, $i, 2;
	}
	else {
	    $i++;
	}
    }
    last if $length == @data;
}

printf "Solution 1: reduced to %d\n", 0+@data;

my %lengths;
for my $unit (ord("a") .. ord("z")) {
    my @d = grep { $unit != ($_ | 0x20) } @data;
    next if @d == @data;
    while (1) {
	my $length = @d;
	my $i = 0;
	while ($i < @d) {
	    if (($d[$i] ^ $d[$i+1]) == 32) {
		splice @d, $i, 2;
	    }
	    else {
		$i++;
	    }
	}
	last if $length == 0+@d;
    }
    $lengths{chr($unit)} = 0+@d;
}

my($best) = sort { $lengths{$a} <=> $lengths{$b} } keys %lengths;

printf "Solution 2: removing %s reduces to %d\n", $best, $lengths{$best};
