#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my @input;


while (<>) {
    chomp;
    push @input, $_;
}

my $ans1 = 0;
for my $input (@input) {
    $_ = $input;
    next if /\[[^\[\]]*(.)((?!\1).)\2\1/;
    s/\[[a-z]*\]/|/g;
    next unless /(.)((?!\1).)\2\1/;
    $ans1++;
}

printf "Solution 1: IPs supporting TLS = %d\n", $ans1;

my $ans2 = 0;
for my $input (@input) {
    my $hypernet;
    my $supernet = $input;
    while ($supernet =~ s/([a-z]*)\[([a-z]*)\]/$1|/) {
	$hypernet .= "$2|";
    }
    # print "S:$supernet H:$hypernet\n";
    while (length $supernet) {
	last unless $supernet =~ /([a-z])((?!\1)[a-z])\1/;
	$supernet = substr $supernet, $-[0]+1;
	next unless $hypernet =~ /$2$1$2/;
	$ans2++;
	last;
    }
}

printf "Solution 2: IPs supporting TLS = %d\n", $ans2;
