#! /usr/bin/perl

use strict;

use Data::Dumper;
use Time::HiRes qw(sleep);

$Data::Dumper::Sortkeys = $Data::Dumper::Indent = 1;

@ARGV = qw(input) unless @ARGV;

my %label;
my @code;
while (<>) {
    chomp;
    s/#.*//;
    if (s/^(\S*)://) {
	$label{$1} = 0+@code;
    }
    my @op = split " ", $_;
    push @code, \@op if @op;
}

my $solution1 = 0;

sub run_code {
    my($code,$reg) = @_;
    my $ip = 0;

    while ($ip < @$code) {
	my($op,$x,$y) = @{$code->[$ip]};
	my $inc = 1;

#	print Dumper $reg;
#	print "$op $x $y\n";

	if (my($label) = $y =~ /@(.*)/) {
	    unless (exists $label{$label}) {
		die "undefined label $label\n"; 
	    }
	    $y = $label{$label}-$ip;
	}
	elsif ($y =~ /[^0-9-]/) {
	    $y = $reg->{$y} ||= 0;
	}
	if ($op eq 'set') {
	    $reg->{$x} = $y;
	}
	elsif ($op eq 'add') {
	    $reg->{$x} += $y;
	}
	elsif ($op eq 'sub') {
	    $reg->{$x} -= $y;
	}
	elsif ($op eq 'mul') {
	    $reg->{$x} *= $y;
	    $solution1++;
	}
	elsif ($op eq 'mod') {
	    $reg->{$x} %= $y;
	}
	elsif ($op eq 'jnz') {
	    $x = $reg->{$x} ||= 0 if $x =~ /[^0-9-]/;
	    if ($x != 0) {
		$inc = $y;
	    }
	}
	elsif ($op eq 'jgz') {
	    $x = $reg->{$x} ||= 0 if $x =~ /[^0-9-]/;
	    if ($x>0) {
		$inc = $y;
	    }
	}
	else {
	    die "unknown op [$op] $x $y ($code->[$ip][2])\n";
	}
	$ip += $inc;
    }
}

run_code(\@code);

printf "Solution 1: %d\n", $solution1;

my $regs = { a => 1 };

run_code(\@code, $regs);

printf "Solution 2: h=%d\n", $regs->{h};
