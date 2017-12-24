#! /usr/bin/perl

use strict;

use Data::Dumper;
$Data::Dumper::Sortkeys = $Data::Dumper::Indent = 1;

@ARGV = qw(input) unless @ARGV;

my @input;
while (<>) {
    chomp;
    if (m,^(\d+)/(\d+),) {
	push @input, [ $1, $2, 0 ];
    }
}

sub find_max_bridge {
    my($ports,$components,$level) = @_;
    my $max_sum = 0;

    my @usable = grep { $_->[0] == $ports || $_->[1] == $ports }
      grep { !$_->[2] } @$components;

#    printf("%sUsable with %d pins, %d = %s\n",
#	   " "x$level,
#	   $ports,
#	   0+@usable,
#	   join(" ", map { $_->[0] . "/" . $_->[1] } @usable)
#	  );

    for my $c (@usable) {
#	printf "%s Using %d/%d\n", " "x$level, $c->[0], $c->[1];
	       
	$c->[2] = 1;
	my $other = $c->[0] == $ports ? $c->[1] : $c->[0];
	my $sum =  $c->[0] + $c->[1] + find_max_bridge($other,$components,$level+1);

	$max_sum = $sum if $sum > $max_sum;
	$c->[2] = 0;
    }

    return $max_sum;
    
}

my $max = find_max_bridge(0,\@input);

printf "Solution 1: %d\n", $max;
