#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;
use Term::ReadLine;

my $term = Term::ReadLine->new("input");

my $solution1;
my $solution2;

my @code;

while (<>) {
    chomp;
    push @code, split /,/;
}

$solution1 = join " ", runcode([@code], 1);
printf "Solution 1: %s\n", $solution1;

$solution2 = join " ", runcode([@code], 5);

printf "Solution 2: %s\n", $solution2;

sub runcode {
    my(#$noun,$verb,
       $mem,@input) = @_;
    my $ip = 0;
    my @output;
#    $mem[1] = $noun;
#    $mem->[2] = $verb;

    while (1) {
	my $full_op = $mem->[$ip++];
	my $op = $full_op % 100;
	$full_op = int($full_op/100);
	my @mode;
	while ($full_op) {
	    push @mode, $full_op % 10;
	    $full_op = int($full_op/10);
	}

	if ($op == 1) {
	    my $a1 = $mem->[$ip++];
	    my $a2 = $mem->[$ip++];
	    my $a3 = $mem->[$ip++];
	    #printf "$a3 = $a1 + $a2\n";
	    $mem->[$a3] =
	      ($mode[0] ? $a1 : $mem->[$a1]) +
	      ($mode[1] ? $a2 : $mem->[$a2]);
	}
	elsif ($op == 2) {
	    my $a1 = $mem->[$ip++];
	    my $a2 = $mem->[$ip++];
	    my $a3 = $mem->[$ip++];
	    #printf "$a3 = $a1 * $a2\n";
	    $mem->[$a3] =
	      ($mode[0] ? $a1 : $mem->[$a1]) *
	      ($mode[1] ? $a2 : $mem->[$a2]);
	}
	elsif ($op == 3) {
	    my $a1 = $mem->[$ip++];
	    my $input;
	    if (@input) {
		$input = shift @input;
	    }
	    else {
		$input = $term->readline("input> ");
	    }
	    printf "input: %s\n", $input;
	    $mem->[$a1] = $input;
	}
	elsif ($op == 4) {
	    my $a1 = $mem->[$ip++];
	    push @output, ($mode[0] ? $a1 : $mem->[$a1]);
	}
	elsif ($op == 5) { # jump if true
	    my $a1 = $mem->[$ip++];
	    my $a2 = $mem->[$ip++];
	    if ($mode[0] ? $a1 : $mem->[$a1]) {
		$ip = $mode[1] ? $a2 : $mem->[$a2];
	    }
	}
	elsif ($op == 6) { # jump if false
	    my $a1 = $mem->[$ip++];
	    my $a2 = $mem->[$ip++];
	    unless ($mode[0] ? $a1 : $mem->[$a1]) {
		$ip = $mode[1] ? $a2 : $mem->[$a2];
	    }
	}
	elsif ($op == 7) { # <
	    my $a1 = $mem->[$ip++];
	    my $a2 = $mem->[$ip++];
	    my $a3 = $mem->[$ip++];
	    if ( ($mode[0] ? $a1 : $mem->[$a1]) <
		 ($mode[1] ? $a2 : $mem->[$a2]) ) {
		$mem->[$a3] = 1;
	    }
	    else {
		$mem->[$a3] = 0;
	    }
	}
	elsif ($op == 8) { # =
	    my $a1 = $mem->[$ip++];
	    my $a2 = $mem->[$ip++];
	    my $a3 = $mem->[$ip++];
	    if ( ($mode[0] ? $a1 : $mem->[$a1]) ==
		 ($mode[1] ? $a2 : $mem->[$a2]) ) {
		$mem->[$a3] = 1;
	    }
	    else {
		$mem->[$a3] = 0;
	    }
	}
	elsif ($op == 99) {
	    last;
	}
	else {
	    warn "Kablam! op = $op\n";
	    return;
	}
    }
    return @output;
}
