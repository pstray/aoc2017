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
    if (my($players,$max_marble,$high_score) =
	/(\d+) players; last marble is worth (\d+) points(?:: high score is (\d+))?/) {
	printf "Running game with %d players, %d max marble", $players, $max_marble;
	if ($high_score) {
	    printf "; high_score should be %d", $high_score;
	}
	printf "\n";
	my $player = 0;
	my @marbles = (0);
	my $current = 0;
	my %score;
	for my $marble (1 .. $max_marble) {
	    $player++;
	    $player = 1 if $player > $players;
	    if ($marble % 23) {
		$current += 2;
		$current %= @marbles;
		splice @marbles, $current+1, 0, $marble;
	    }
	    else {
		$score{$player} += $marble;
		$current -= 7;
		$current %= @marbles;
		# printf "-- $current\n"
		my $points = splice @marbles, $current+1, 1;
		$score{$player} += $points;
#		printf "-- %s\n", join " ", map { sprintf "%5d", $_ }
#		  $marble, $current, $points;
		
	    }
	    # printf "[%3d]: %s\n", $player, join " ", map { sprintf "%2d", $_ } @marbles;
	}
	my($winner) = sort { $score{$b} <=> $score{$a} } keys %score;
	printf "  Solution 1: %d wins, %d score\n", $winner, $score{$winner};
	
    }
    else {
	warn "unparsable input $.: $_\n";
    }
}
