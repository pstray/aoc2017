#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;
use open ':locale';

use POSIX qw(ceil);

use Data::Dumper;

eval { require "../../lib/common.pl"; };
warn "$@" if $@;

$Data::Dumper::Sort = 1;

my $solution1;
my $solution2;

my %react;;

while (<>) {
    chomp;
    if (my($in,$out) = /(.*)\s+=>\s*(.*)/) {
	my @in = split /\s*,\s*/, $in;
	my @out = split /\s*,\s*/, $out;
	for my $e (@in, @out) {
	    if ($e =~ /^(?<amount>\d+)\s+(?<element>\S+)$/) {
		$e = { %+ };
	    }
	}
	if (@out>1) {
	    die "Kablam! $_\n";
	}
	($out) = @out;

	die if $react{$out->{element}};

	$react{$out->{element}} = { in => [ @in ], out => $out->{amount} };

    }
    else {
	die "Kablam! $_\n";
    }
}

my %need = (FUEL => 1);
my %have = ();
my %used = ();
my %prod = ();

sub react {
    my(%need) = @_;
    my(%have);
    local $Data::Dumper::Indent = 0;

    while (keys %need) {
	# printf "%s\n", Data::Dumper->Dump([\%have],[qw(have)]);
	# printf "%s\n", Data::Dumper->Dump([\%need],[qw(need)]);
	# printf "\n";
	for my $e (sort { $need{$b} <=> $need{$a}} keys %need) {
	    my $amount = delete $need{$e};
	    if ($e eq 'ORE') {
		$have{ORE} -= $amount;
		next;
	    }

	    my($in) = $react{$e}{in};
	    my($out) = $react{$e}{out};

	    while ($have{$e} < $amount) {
		my $missing = $amount - $have{$e};
		my $n = ceil($missing/$out);
		$have{$e} += $n*$out;
		for my $i (@$in) {
		    $need{$i->{element}} += $n*$i->{amount};
		}
	    }
	    $have{$e} -= $amount;
	}
    }
    return -$have{ORE};
}

$solution1 = react(FUEL => 1);

printf "Solution 1: %s\n", join " ", $solution1;

$solution2 = bin_search(1, 2*int(1000000000000/$solution1),
			sub { react(FUEL => $_[0]) }, 1000000000000,
		       );

printf "Solution 2: %s\n", join " ", $solution2;
