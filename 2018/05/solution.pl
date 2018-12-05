#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

my $data = do { local $/ = undef; <> };
chomp $data;

$_ = $data;
while (1) {
    my $length = length;
    s/([a-z])([A-Z])/$1 eq lc $2 ? "" : "$1$2"/ge;
    s/([A-Z])([a-z])/$1 eq uc $2 ? "" : "$1$2"/ge;
    last if $length == length;
}


printf "Solution 1: reduced to %d\n", length;

my %lengths;
for my $unit ("a" .. "z") {
    $_ = $data;
    s/$unit//gi || next;
    while (1) {
	my $length = length;
	s/([a-z])([A-Z])/$1 eq lc $2 ? "" : "$1$2"/ge;
	s/([A-Z])([a-z])/$1 eq uc $2 ? "" : "$1$2"/ge;
	last if $length == length;
    }
    $lengths{$unit} = length;
}

my($best) = sort { $lengths{$a} <=> $lengths{$b} } keys %lengths;

printf "Solution 2: removing %s reduces to %d\n", $best, $lengths{$best};
