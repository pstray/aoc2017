#! /usr/bin/perl

use strict;
use Data::Dumper;
$Data::Dumper::Sortkeys = $Data::Dumper::Indent = 1;

use Clone qw(clone);

@ARGV = qw(input) unless @ARGV;

my($initial_wall);
while (<>) {
    chomp;
    if (my($depth,$range) = /^(\d+):\s*(\d+)/) {
	$initial_wall->[$depth] =
	  { range => $range,
	    dir => 1,
	    pos => 0,
	  };
    }
    else {
	die "Unhandled input [$_]\n";
    }
}

sub update_wall {
    my($wall) = @_;
    for my $w (@$wall) {
	next unless $w;
	$w->{pos} += $w->{dir};
	if ($w->{pos} == $w->{range}-1 || $w->{pos} == 0) {
	    $w->{dir} *= -1;
	}
    }
}

my $wall = clone($initial_wall);
my $severity = 0;
for my $depth (0 .. @$wall) {
    my $layer = $wall->[$depth];
    if ($layer && $layer->{pos} == 0) {
	$severity += $depth * $layer->{range};
    }
    # update
    update_wall($wall);
}

printf "Solution 1: severity of %s\n", $severity;


my $done = 0;
my $delay = 0;

$| = 1;

my $start_wall = clone($initial_wall);

travers:
while (!$done) {

    $wall = clone($start_wall);

    for my $depth (0 .. @$wall) {
#	draw_wall(0, $depth);

	my $layer = $wall->[$depth];
	if ($layer) {
	    if ($layer->{pos} == 0) {
		#printf "Caught at %d after %d ps delay\n", $depth, $delay;  
		$delay++;
		update_wall($start_wall);
		redo travers;
	    }
	}
	
#	draw_wall(0, $depth);
	update_wall($wall);
	
    }

    $done++;
}

printf "Solution 2: delay %d\n", $delay;

__END__
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
	    my $w = $wall->[$d];
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
