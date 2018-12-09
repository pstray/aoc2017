#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my $multiplier = 1;

if (@ARGV >= 2) {
    $multiplier = 100;
    pop @ARGV;
}


while (<>) {
    chomp;
    if (my($players,$max_marble,$high_score) =
	/(\d+) players; last marble is worth (\d+) points(?:: high score is (\d+))?/) {
	$max_marble *= $multiplier;
	printf "Running game with %d players, %d max marble", $players, $max_marble;
	if ($high_score) {
	    printf "; high_score should be %d", $high_score;
	}
	printf "\n";
	my $player = 0;
	my $current = [0];
	$current->[1] = $current->[2] = $current;
	my $first = $current;
	my %score;
	for my $marble (1 .. $max_marble) {
	    $player++;
	    $player = 1 if $player > $players;
	    if ($marble % 23) {
		$current = $current->[1] for 1..2;
		my $t = [ $marble, $current, $current->[2] ];
		$current = $current->[2] = $t->[2][1] = $t;
	    }
	    else {
		$score{$player} += $marble;
		$current = $current->[2] for 1..7;
		my $points = $current->[0];

		$current->[2][1] = $current->[1];
		$current->[1][2] = $current->[2];

		$current = $current->[1];
		
		$score{$player} += $points;
#		printf "-- %s\n", join " ", map { sprintf "%5d", $_ }
#		  $marble, $current, $points;
		
	    }
	    # printf "[%3d]: %s\n", $player, join " ", map { sprintf "%2d", $_ } @marbles;
	    # print Dumper $first;
	}
	my($winner) = sort { $score{$b} <=> $score{$a} } keys %score;
	printf "  Solution 1: %d wins, %d score\n", $winner, $score{$winner};
	
    }
    else {
	warn "unparsable input $.: $_\n";
    }
}
