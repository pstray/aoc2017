#! /usr/bin/perl
#
# Copyright (C) 2019-2020 by Peder Stray <peder@ninja.no>
#

use strict;

$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

sub gcd {
    my ($b, @rest) = @_;
    for my $a (@rest) {
	($a,$b) = ($b,$a) if $a > $b;
	while ($a) {
	    ($a, $b) = ($b % $a, $a);
	}
    }
    return $b;
}

sub lcm {
    my($a,@rest) = @_;
    for my $b (@rest) {
	$a = $a*$b / gcd($a,$b);
    }
    return $a;
}

sub permute_run {
    my($list,$proc,@perm) = @_;
    if (@$list) {
	for my $i (0 .. @$list-1) {
	    my @sub_list = (@{$list}[0..$i-1], @{$list}[$i+1 .. @$list-1]);
	    permute_run(\@sub_list, $proc, @perm, $list->[$i]);
	}
    }
    else {
	$proc->(@perm);
    }
}

sub bin_search {
    my($low,$high,$sub,$t) = @_;
    while ($low < $high) {
	my $mid = int(($low+$high)/2);
	my $res = $sub->($mid);
	if ($res < $t) {
	    $low = $mid+1;
	}
	elsif ($res > $t) {
	    $high = $mid-1;
	}
	else {
	    return $mid;
	}
    }
    return $high;
}

sub max {
    my(@list) = @_;
    my $max = shift @list;
    for my $val (@list) {
	$max = $val if $val > $max;
    }
    return $max;
}

sub min {
    my(@list) = @_;
    my $min = shift @list;
    for my $val (@list) {
	$min = $val if $val < $min;
    }
    return $min;
}

1;
