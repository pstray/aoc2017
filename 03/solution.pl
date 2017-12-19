#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my $input = do { local $/ = undef; <> };
chomp $input;

my $max_x = 0;
my $min_x = 0;
my $max_y = 0;
my $min_y = 0;
my $pos_x = 0;
my $pos_y = 0;

$input--;
while ($input > 0) {
    printf "I> = %s\n", $input;
    my $d = $max_x-$min_x;
    if ($input > $d) {
	$max_x++;
	$input -= $d+1;
	$pos_x = $max_x;
    }
    else {
	$pos_x += $input;
	$input = 0;
    }
    last unless $input;

    printf "I^ = %s\n", $input;
    my $d = $max_y-$min_y;
    if ($input > $d) {
	$max_y++;
	$input -= $d+1;
	$pos_y = $max_y;
    }
    else {
	$pos_y += $input;
	$input = 0;
    }
    last unless $input;

    printf "I< = %s\n", $input;
    my $d = $max_x-$min_x;
    if ($input > $d) {
	$min_x--;
	$input -= $d+1;
	$pos_x = $min_x;
    }
    else {
	$pos_x -= $input;
	$input = 0;
    }
    last unless $input;

    printf "Iv = %s\n", $input;
    my $d = $max_y-$min_y;
    if ($input > $d) {
	$min_y--;
	$input -= $d+1;
	$pos_y = $min_y;
    }
    else {
	$pos_y -= $input;
	$input = 0;
    }
    last unless $input;
    
}

printf "Solution 1: [%d,%d] => %d\n", $pos_x, $pos_y, abs($pos_x)+abs($pos_y);
