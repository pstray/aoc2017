#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

my @data;

while (<>) {
    chomp;
    push @data, split " ";
}

sub checksum {
    my($data,$index) = @_;
    #printf "[";
    my $checksum = 0;
    my $value = 0;
    my $childs = $data->[$index++];
    my $metas = $data->[$index++];
    my(@childs,@metas);
    for (1 .. $childs) {
	my($cs,$v,$i) = checksum($data,$index);
	$index = $i;
	$checksum += $cs;
	push @childs, $v;
    }
    for (1 .. $metas) {
	#printf " %d", $data->[$index];
	my $m = $data->[$index++];
	$checksum += $m;
	$value += @childs ? $childs[$m-1] : $m;
    }
    #printf " ]";
    return wantarray ? ($checksum,$value,$index) : $checksum;
}

my($solution1,$solution2) = checksum(\@data,0);
#printf "\n";

printf "Solution 1: %d\n", $solution1;
printf "Solution 2: %d\n", $solution2;
