#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

while (<>) {
    chomp;
    my $input = $_;
    
    my $data = "37";
    my $pos1 = 0;
    my $pos2 = 1;

    my $len = length $data;
    
    while ($len < $input + 10) {
	my $s1 = substr($data,$pos1,1);
	my $s2 = substr($data,$pos2,1);
	$data .= $s1+$s2;
	$len = length $data;
	$pos1 = ($pos1+$s1+1) % $len;
	$pos2 = ($pos2+$s2+1) % $len;
	#printf "Data: %s %d %d \n", $data, $pos1, $pos2;
    }

    printf "Solution 1: at %d = %s\n", $input, substr($data,$input,10);

    my $pos = index $data, $input;
    my $input_len = length $input;
    while ($pos<0) {
	my $s1 = substr($data,$pos1,1);
	my $s2 = substr($data,$pos2,1);
	$data .= $s1+$s2;
	$len = length $data;
	$pos1 = ($pos1+$s1+1) % $len;
	$pos2 = ($pos2+$s2+1) % $len;
	# printf "Data: %s %d %d \n", $data, $pos1, $pos2;
	$pos = index $data, $input, $len-$input_len-1;
    }

    printf "Solution 2: %s seen at %d\n", $input, $pos; 
}

    
