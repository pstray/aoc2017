#! /usr/bin/perl

use strict;

use Data::Dumper;
$Data::Dumper::Sortkeys = $Data::Dumper::Indent = 1;

@ARGV = qw(input) unless @ARGV;

my %states;
my %tape;
my $cursor = 0;

my $begin_state;
my $diag_after;

my $state;
my $value;
while (<>) {
    chomp;
    next unless /\S/;

    if (/^Begin in state (\w+)\.\s*$/) {
	$begin_state = $1;
    }
    elsif (/^Perform a diagnostic checksum after (\d+) steps\.\s*$/) {
	$diag_after = $1;
    }
    elsif (/^In state (\w+):\s*$/) {
	$state = $1;
    }
    elsif (/^\s*If the current value is (\d+):\s*$/) {
	$value = $1;
    }
    elsif (/^\s*- Write the value (\d+)\.\s*$/) {
	$states{$state}[$value][0] = $1;
    }
    elsif (/^\s*- Move one slot to the right.\s*$/) {
	$states{$state}[$value][1] = 1;
    }
    elsif (/^\s*- Move one slot to the left.\s*$/) {
	$states{$state}[$value][1] = -1;
    }
    elsif (/^\s*- Continue with state (\w+).\s*$/) {
	$states{$state}[$value][2] = $1;
    }
    else {
	die "Unhandled input [$_]\n";
    }
}

# print Data::Dumper->Dump([\%states],[qw(state)]);

$state = $begin_state;
my $iteration = 0;
while ($iteration++ < $diag_after) {
    my($write_value,$direction,$next_state) = @{$states{$state}[$tape{$cursor}]};

    #print "$state $cursor: $next_state $direction $write_value\n";
    if ($write_value) {
	$tape{$cursor} = 1;
    }
    else {
	delete $tape{$cursor};
    }
    $cursor += $direction;
    $state = $next_state;
}

printf "Solution 1: %d positions with 1\n", 0+keys %tape;
