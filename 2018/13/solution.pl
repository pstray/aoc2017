#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my %track;
my $cart;
my $carts;

my %turn;

$turn{0}{1}{0} = [ 0, -1 ];
$turn{0}{0}{-1} = [ -1, 0 ];
$turn{0}{-1}{0} = [ 0, 1 ];
$turn{0}{0}{1} = [ 1, 0 ];

$turn{1}{1}{0} = [ 1, 0 ];
$turn{1}{0}{-1} = [ 0, -1 ];
$turn{1}{-1}{0} = [ -1, 0 ];
$turn{1}{0}{1} = [ 0, 1 ];

$turn{2}{1}{0} = [ 0, 1 ];
$turn{2}{0}{1} = [ -1, 0 ];
$turn{2}{-1}{0} = [ 0, -1 ];
$turn{2}{0}{-1} = [ 1, 0 ];

my $y = 0;
while (<>) {
    chomp;
    my @line = split //;
    my $x = 0;
    for my $e (@line) {
	
	if ($e =~ m,[-|/\\+],) {
	    $track{$y}{$x} = $e;
	}
	elsif ($e eq "^") {
	    $track{$y}{$x} = "|";
	    $cart->{$y}{$x} = [ 0, -1, 0 ];
	    $carts++;
	}
	elsif ($e eq ">" ) {
	    $track{$y}{$x} = "-";
	    $cart->{$y}{$x} = [ 1, 0, 0 ];
	    $carts++;
	}
	elsif ($e eq "v" ) {
	    $track{$y}{$x} = "|";
	    $cart->{$y}{$x} = [ 0, 1, 0 ];
	    $carts++;
	}
	elsif ($e eq "<" ) {
	    $track{$y}{$x} = "-";
	    $cart->{$y}{$x} = [ -1, 0, 0 ];
	    $carts++;
	}
	elsif ($e eq " ") {
	}
	else {
	    printf "Unrecognized type '%s' at %d,%d\n", $e, $x, $y;
	}
	$x++;
    }
    $y++;
}

my($crash_x, $crash_y);
my($last_x, $last_y);
my $loop = 0;



my $ncart;
loop:
while (1) {
    $loop++;
    $ncart = {};
  forloop:
    for my $y (sort {$a<=>$b} keys %$cart) {
	for my $x (sort {$a<=>$b} keys %{$cart->{$y}}) {
	    my $c = delete $cart->{$y}{$x};
	    next unless $c;
	    my($dx,$dy,$next_turn) = @$c;
	    printf "loop %d: cart at %d,%d = %d,%d,%d\n",
	      $loop, $x, $y, $dx, $dy, $next_turn
	      if 0;
	    my($xx,$yy) = ($x+$dx,$y+$dy);
	    # printf "  [%1s]->[%1s]\n", $track{$y}{$x}, $track{$yy}{$xx};
	    if ($cart->{$yy}{$xx} || $ncart->{$yy}{$xx}) {
		printf "loop %d, %d left: Crash at %d, %d\n", $loop, $carts, $xx, $yy;
		$crash_x = $xx unless defined $crash_x;
		$crash_y = $yy unless defined $crash_y;
		delete $cart->{$yy}{$xx};
		delete $ncart->{$yy}{$xx};
		$carts -= 2;
		next;
	    }
	
	    if ($track{$yy}{$xx} =~ m,[-|],) {
		# continue on
	    }
	    elsif ($track{$yy}{$xx} eq "/") {
		if ($dx) {
		    $dy = $dx>0 ? -1 : 1;
		    $dx = 0;
		}
		else {
		    $dx = $dy>0 ? -1 : 1;
		    $dy = 0;
		}
	    }
	    elsif ($track{$yy}{$xx} eq "\\") {
		if ($dx) {
		    $dy = $dx>0 ? 1 : -1;
		    $dx = 0;
		}
		else {
		    $dx = $dy>0 ? 1 : -1;
		    $dy = 0;
		}
	    }
	    elsif ($track{$yy}{$xx} eq "+") {
		($dx,$dy) = @{$turn{$next_turn}{$dx}{$dy}};
		$next_turn = ($next_turn+1)%3;
	    }
	    else {
		die "wtf [$track{$y}{$x}-$track{$yy}{$xx}]";
	    }
	    # printf "    %d,%d,%d\n", $dx, $dy, $next_turn;

	    
	    $ncart->{$yy}{$xx} = [ $dx, $dy, $next_turn ];
	}
    }
    $cart = $ncart;
    last if $carts < 2;
}

for my $y (keys %$cart) {
    for my $x (keys %{$cart->{$y}}) {
	$last_x = $x;
	$last_y = $y;
    }
}

printf "\n";

printf "Solution 1: crash at %d,%d\n", $crash_x, $crash_y;
printf "Solution 2: last at %d,%d\n", $last_x, $last_y;
