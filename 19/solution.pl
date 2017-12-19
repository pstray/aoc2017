#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my @diagram;
while (<>) {
    chomp;
    push @diagram, [ split //, $_];
}

my $letters = "";
my $pos_y = 0;
my $pos_x = index join("", @{$diagram[$pos_y]}), '|';

my $dir_x = 0;
my $dir_y = 1;

while (1) {
    my $c = $diagram[$pos_y][$pos_x];
    if ($c eq '|' or $c eq '-') {
	if ($dir_x) {
	    $pos_x += $dir_x;
	}
	else {
	    $pos_y += $dir_y;
	}
    }
    elsif ($c eq '+') {
	if ($dir_x) {
	    
	}
	
    }
}


printf "Solution 1: [%d,%d] %s\n", $pos_x, $pos_y, $letters;

