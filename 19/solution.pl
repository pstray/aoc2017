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

snailtrail:
while (1) {
    my $c = $diagram[$pos_y][$pos_x];
    if ($c eq '|' or $c eq '-') {
	# continue on...
    }
    elsif ($c =~ /[[:alpha:]]/) {
	$letters .= $c;
    }
    elsif ($c eq '+') {
	# turn
	if ($dir_x) {
	    $dir_x = 0;
	    if ($diagram[$pos_y-1][$pos_x] ne ' ') {
		$dir_y = -1;
	    }
	    elsif ($diagram[$pos_y+1][$pos_x] ne ' ') {
		$dir_y = 1;
	    }
	}
	else {
	    $dir_y = 0;
	    if ($diagram[$pos_y][$pos_x-1] ne ' ') {
		$dir_x = -1;
	    }
	    elsif ($diagram[$pos_y][$pos_x+1] ne ' ') {
		$dir_x = 1;
	    }
	}
	
    }
    elsif ($c eq ' ') {
	# possibly at the end
	last snailtrail;
    }
    else {
	die "What am i going to do with [$c] at [$pos_x,$pos_y] going ($dir_x,$dir_y)\n";
    }
    $pos_x += $dir_x;
    $pos_y += $dir_y;
}

printf "Solution 1: [%d,%d] %s\n", $pos_x, $pos_y, $letters;

