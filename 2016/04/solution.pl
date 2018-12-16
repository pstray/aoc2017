#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my $ans1 = 0;
my $ans2;
while (<>) {
    chomp;
    if (my($name,$id,$checksum) = /^([a-z-]+)-(\d+)\[([a-z]{5})\]$/) {
	my %c;
	for my $c (split //, $name) {
	    $c{$c}++;
	}
	delete $c{"-"};
	my $cs = join "", (sort {$c{$b}<=>$c{$a} || $a cmp $b} keys %c)[0..4];

	# printf "%s %d [ %s %s ]\n", $name, $id, $checksum, $cs;
	next unless $cs eq $checksum;
	$ans1 += $id;

	my $dname = join "",
	  map { $_ eq '-' ? ' ' :
		chr((ord($_)-ord('a')+$id) % 26 + ord('a')) } split //, $name;

	if ($dname =~ /north.*pole.*object/i) {
	    $ans2 = $id;
	}
    }
    else {
	warn "unparsable input:$.: $_\n";
    }
}

printf "Solution 1: sum of ids of valid rooms = %d\n", $ans1;
printf "Solution 1: North Pole object are in sector = %d\n", $ans2;
