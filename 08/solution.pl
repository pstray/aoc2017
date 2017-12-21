#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my %reg;

while (<>) {
    chomp;
    my($reg,$op,$val,$if,$t_reg,$t_op,$t_val) = split " ";
    if ($t_op eq '<=') {
	next unless $reg{$t_reg} <= $t_val;
    }
    elsif ($t_op eq '>=') {
	next unless $reg{$t_reg} >= $t_val;
    }
    elsif ($t_op eq '!=') {
	next unless $reg{$t_reg} != $t_val;
    }
    elsif ($t_op eq '==') {
	next unless $reg{$t_reg} == $t_val;
    }
    elsif ($t_op eq '<') {
	next unless $reg{$t_reg} < $t_val;
    }
    elsif ($t_op eq '>') {
	next unless $reg{$t_reg} > $t_val;
    }
    else {
	die "Unhandled t_op [$t_op]\n";
    }
    if ($op eq 'dec') {
	$reg{$reg} -= $val;
    }
    elsif ($op eq 'inc') {
	$reg{$reg} += $val;
    }
    else {
	die "Unhandles op [$op]\n";
    }
}

my($max_val) = sort {$b<=>$a} values %reg;

printf "Solution 1: %d\n", $max_val;
