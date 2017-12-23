#! /usr/bin/perl

use strict;

use Data::Dumper;
use Time::HiRes qw(sleep);

$Data::Dumper::Sortkeys = $Data::Dumper::Indent = 1;

@ARGV = qw(input) unless @ARGV;

my @code;
while (<>) {
    chomp;
    push @code, [ split " ", $_ ];
}

my $solution1 = 0;

sub run_code {
    my($code,$reg) = @_;
    my $ip = 0;

    while ($ip < @$code) {
	my($op,$x,$y) = @{$code->[$ip]};
	my $inc = 1;

	$y = $reg->{$y} ||= 0 if $y =~ /[^0-9-]/;

	if ($op eq 'set') {
	    $reg->{$x} = $y;
	}
	elsif ($op eq 'sub') {
	    $reg->{$x} -= $y;
	}
	elsif ($op eq 'mul') {
	    $reg->{$x} *= $y;
	    $solution1++;
	}
	elsif ($op eq 'jnz') {
	    $x = $reg->{$x} ||= 0 if $x =~ /[^0-9-]/;
	    if ($x != 0) {
		$inc = $y;
	    }
	}
	else {
	    die "unknown op [$op] $x $y ($code[$ip][2])\n", join " ", $op, $x, $y;
	}
	$ip += $inc;
    }

    return $reg;
}

run_code(\@code);

printf "Solution 1: %d\n", $solution1;

