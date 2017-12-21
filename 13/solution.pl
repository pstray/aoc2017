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
