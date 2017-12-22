#! /usr/bin/perl

use strict;

use Data::Dumper;
$Data::Dumper::Sortkeys = $Data::Dumper::Indent = 1;

@ARGV = qw(input) unless @ARGV;

my @grid;
while (<>) {
    chomp;
    push @grid, $_;
}

my %infected;

my $min_x = 0;
my $max_x = 0;
my $min_y = 0;
my $max_y = 0;

my $y_mid = int(@grid/2);
my $x_mid = int(length($grid[$y_mid])/2);
for my $y (0 .. @grid-1) {
    my $iy = $y-$y_mid;
    for my $x (0 .. length($grid[$y])-1) {
	my $ix = $x-$x_mid;
	$infected{$ix,$iy} = substr($grid[$y], $x, 1) eq '#';
	$min_x = $ix if $ix < $min_x;
	$max_x = $ix if $ix > $max_x;
    }
    $min_y = $iy if $iy < $min_y;
    $max_y = $iy if $iy > $max_y;
}

my $pos_x = 0;
my $pos_y = 0;
my $dir = 0;
my $infections = 0;
my $iterations = 10_000;
#dump_map(0);
for (1 .. $iterations) {
    if ($infected{$pos_x,$pos_y}) {
	$dir += 1; # turn right
    }
    else {
	$dir -= 1; # turn left
    }
    $infected{$pos_x,$pos_y} = 1-$infected{$pos_x,$pos_y};
    $infections++ if $infected{$pos_x,$pos_y};
    $dir %= 4;
    if ($dir == 0) { # up
	$pos_y--;
	$min_y = $pos_y if $pos_y < $min_y;
    }
    elsif ($dir == 1) { # right
	$pos_x++;
	$max_x = $pos_x if $pos_x > $max_x;
    }
    elsif ($dir == 2) { # down
	$pos_y++;
	$max_y = $pos_y if $pos_y > $max_y;
    }
    elsif ($dir == 3) { # left;
	$pos_x--;
	$min_x = $pos_x if $pos_x < $min_x;
    }
    else {
	die "dir is weird [$dir]\n";
    }
#    dump_map($_);
#    sleep 1;
}

printf "Solution 1: %d infections\n", $infections;





sub dump_map {
    my($iteration) = @_;
    my @extra = (
		 sprintf("x = %3d", $pos_x),
		 sprintf("y = %3d", $pos_y),
		 sprintf("d = %s", (qw(UP RIGHT DOWN LEFT))[$dir]),
		);
    printf "--[%3d ]--%s\n",$iteration,"-" x 60;
    for my $y ($min_y-3 .. $max_y+3) {
	my $l = " ";
	for my $x ($min_x-3 .. $max_x+3) {
	    $l .= sprintf "%s ", $infected{$x,$y} ? '#' : '.';
	}
	if ($pos_y == $y) {
	    substr($l,2*($pos_x-$min_x+3)  ,1) = '[';
	    substr($l,2*($pos_x-$min_x+3)+2,1) = ']';
	}
	printf "%s  %s\n", $l, shift @extra;
    }
}
