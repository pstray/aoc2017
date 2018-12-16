#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my %kp1 = ( 2 => { 0 => '1', 1 => '2', 2 => '3' }, 
	    1 => { 0 => '4', 1 => '5', 2 => '6' },
	    0 => { 0 => '7', 1 => '8', 2 => '9' },
	  );

my $x1 = 1;
my $y1 = 1;

my %kp2 = ( 4 => {                     2 => '1'                     }, 
	    3 => {           1 => '2', 2 => '3', 3 => '4'           },
	    2 => { 0 => '5', 1 => '6', 2 => '7', 3 => '8', 4 => '9' }, 
	    1 => {           1 => 'A', 2 => 'B', 3 => 'C'           },
	    0 => {                     2 => 'D'                     }, 
	  );

my $x2 = 0;
my $y2 = 2;

# print Dumper \%kp;

my $ans1 = "";
my $ans2 = "";
while (<>) {
    chomp;
    for my $d (split //) {
	if ($d eq 'U') {
	    $y1++if defined $kp1{$y1+1}{$x1};
	    $y2++if defined $kp2{$y2+1}{$x2};
	}
	elsif ($d eq 'D') {
	    $y1--if defined $kp1{$y1-1}{$x1};
	    $y2--if defined $kp2{$y2-1}{$x2};
	}
	elsif ($d eq 'R') {
	    $x1++if defined $kp1{$y1}{$x1+1};
	    $x2++if defined $kp2{$y2}{$x2+1};
	}
	elsif ($d eq 'L') {
	    $x1--if defined $kp1{$y1}{$x1-1};
	    $x2--if defined $kp2{$y2}{$x2-1};
	}
    }
    $ans1 .= $kp1{$y1}{$x1};
    $ans2 .= $kp2{$y2}{$x2};
}

printf "Solution 1: the code is %s\n", $ans1;
printf "Solution 2: the code is %s\n", $ans2;

