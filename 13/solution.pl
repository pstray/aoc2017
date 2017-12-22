#! /usr/bin/perl

use strict;
use Data::Dumper;
$Data::Dumper::Sortkeys = $Data::Dumper::Indent = 1;

@ARGV = qw(input) unless @ARGV;

my(@wall,%wall);
while (<>) {
    chomp;
    if (my($depth,$range) = /^(\d+):\s*(\d+)/) {
	$wall{$depth} = $wall[$depth] =
	  { range => $range,
	    dir => 1,
	    pos => 0,
	  };
    }
    else {
	die "Unhandled input [$_]\n";
    }
}

my $severity = 0;
for my $depth (0 .. @wall) {
    my $layer = $wall[$depth];
    if ($layer && $layer->{pos} == 0) {
	$severity += $depth * $layer->{range};
    }
    # update
    for my $w (values %wall) {
	$w->{pos} += $w->{dir};
	if ($w->{pos} == $w->{range}-1 || $w->{pos} == 0) {
	    $w->{dir} *= -1
	}
    }
}

printf "Solution 1: severity of %s\n", $severity;

sub reset_wall {
    for (values %wall) {
	$_->{dir} = 1;
	$_->{pos} = 0;
    }
}

sub update_wall {
    for my $w (values %wall) {
	$w->{pos} += $w->{dir};
	if ($w->{pos} == $w->{range}-1 || $w->{pos} == 0) {
	    $w->{dir} *= -1;
	}
    }
}

my $done = 0;
my $delay = 0;
my $time = 0;

$| = 1;

travers:
while (!$done) {

    reset_wall();

    my $depth = -1;

    printf "Traversing from depth=%d, delay=%d...\n", $depth, $delay;

    while ($depth < @wall) {
	draw_wall(0, $depth);
	$time++;
	$depth++;

	my $layer = $wall[$depth];
	if ($layer) {
	    if ($layer->{pos} == 0) {
		$delay++;
		$depth--;
	    }
	}
	
	draw_wall(0, $depth);

	update_wall();

    }

    $done++;
}

printf "Solution 2: delay %d\n", $delay;

sub draw_wall {
    my($start, $depth) = @_;
    $start = 0 if $start < 0;
    printf "\e[H\e[2J";
    printf "D=%d T=%d\n", $depth, $time;
    for my $d ($start .. $start + 15) {
	printf " %3d", $d;
    }
    print "\n";
    for my $line (0 .. 19) {
	for my $d ($start .. $start + 15) {
	    my $w = $wall[$d];
	    my $s = " ";
	    if ($w) {
		$s = "S" if $w->{pos} == $line;
		if ($d == $depth && $line == 0) {
		    $s = "($s)";
		}
		elsif ($line < $w->{range}) {
		    $s = "[$s]";
		}
		else {
		    $s = " $s ";
		}
	    }
	    else {
		if ($d == $depth && $line == 0) {
		    $s = "($s)";
		}
		else {
		    $s = " $s ";
		}
	    }
	    printf " %s", $s;
	}
	printf "\n";
    }
    sleep 1 if $start <= $depth && $depth <= $start+15;
}
