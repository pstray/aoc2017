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

my $value = $input;
$value--;
while ($value > 0) {
    # printf "I> = %s\n", $value;
    my $d = $max_x-$min_x;
    if ($value > $d) {
	$max_x++;
	$value -= $d+1;
	$pos_x = $max_x;
    }
    else {
	$pos_x += $value;
	$value = 0;
    }
    last unless $value;

    # printf "I^ = %s\n", $value;
    my $d = $max_y-$min_y;
    if ($value > $d) {
	$max_y++;
	$value -= $d+1;
	$pos_y = $max_y;
    }
    else {
	$pos_y += $value;
	$value = 0;
    }
    last unless $value;

    # printf "I< = %s\n", $value;
    my $d = $max_x-$min_x;
    if ($value > $d) {
	$min_x--;
	$value -= $d+1;
	$pos_x = $min_x;
    }
    else {
	$pos_x -= $value;
	$value = 0;
    }
    last unless $value;

    # printf "Iv = %s\n", $value;
    my $d = $max_y-$min_y;
    if ($value > $d) {
	$min_y--;
	$value -= $d+1;
	$pos_y = $min_y;
    }
    else {
	$pos_y -= $value;
	$value = 0;
    }
    last unless $value;
    
}

printf "Solution 1: [%d,%d] => %d\n", $pos_x, $pos_y, abs($pos_x)+abs($pos_y);

my %grid;
$min_x = $max_x = $min_y = $max_y = $pos_x = $pos_y = 0;
my $value;

$grid{0,0} = 1;

spiral:
while (1) {

    $max_x++;
    for ($min_x+1 .. $max_x) {
	$pos_x = $_;
	$value = $grid{$pos_x,$pos_y} =
	  $grid{$pos_x-1,$pos_y+1}+
	  $grid{$pos_x  ,$pos_y+1}+
	  $grid{$pos_x+1,$pos_y+1}+
	  $grid{$pos_x-1,$pos_y};
	last spiral if $value > $input;
    }

    $max_y++;
    for ($min_y+1 .. $max_y) {
	$pos_y = $_;
	$value = $grid{$pos_x,$pos_y} =
	  $grid{$pos_x-1,$pos_y-1}+
	  $grid{$pos_x-1,$pos_y}+
	  $grid{$pos_x-1,$pos_y+1}+
	  $grid{$pos_x  ,$pos_y-1};
	last spiral if $value > $input;
    }

    $min_x--;
    for (reverse $min_x .. $max_x-1) {
	$pos_x = $_;
	$value = $grid{$pos_x,$pos_y} =
	  $grid{$pos_x+1,$pos_y-1}+
	  $grid{$pos_x  ,$pos_y-1}+
	  $grid{$pos_x-1,$pos_y-1}+
	  $grid{$pos_x+1,$pos_y};
	last spiral if $value > $input;
    }

    $min_y--;
    for (reverse $min_y .. $max_y-1) {
	$pos_y = $_;
	$value = $grid{$pos_x,$pos_y} =
	  $grid{$pos_x+1,$pos_y+1}+
	  $grid{$pos_x+1,$pos_y  }+
	  $grid{$pos_x+1,$pos_y-1}+
	  $grid{$pos_x  ,$pos_y+1};
	last spiral if $value > $input;
    }

}

printf "Solution 2: [%d,%d] => %d\n", $pos_x, $pos_y, $value;
