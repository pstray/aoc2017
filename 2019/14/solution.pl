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

$Data::Dumper::Indent = 0;

while (keys %need) {
    # printf "%s\n", Data::Dumper->Dump([\%have],[qw(have)]);
    # printf "%s\n", Data::Dumper->Dump([\%need],[qw(need)]);
    # printf "\n";
    for my $e (sort { $need{$b} <=> $need{$a}} keys %need) {
	my $need = delete $need{$e};
	if ($e eq 'ORE') {
	    $have{ORE} -= $need;
	    $used{ORE} += $need;
	    next;
	}

	my($in) = $react{$e}{in};
	my($out) = $react{$e}{out};

	while ($have{$e} < $need) {
	    $have{$e} += $out;
	    $prod{$e} += $out;
	    for my $i (@$in) {
		$need{$i->{element}} += $i->{amount};
	    }
	}
	$have{$e} -= $need;
	$used{$e} += $need;
    }
}

$solution1 = $used{ORE};

printf "Solution 1: %s\n", join " ", $solution1;

printf "%s\n", Data::Dumper->Dump([\%prod],[qw(prod)]);
printf "%s\n", Data::Dumper->Dump([\%used],[qw(used)]);
printf "%s\n", Data::Dumper->Dump([\%have],[qw(have)]);

my %cc = map { $_ => 1 } keys %have;
delete $cc{$_} for qw(ORE FUEL);

my %cv;

$have{ORE} += 1000000000000;
my $skipped = 0;

while (1) {

    for my $e (keys %cc) {
	unless ($have{$e}) {
	    delete $cc{$e};
	    $cv{$e} = $prod{FUEL};
	    printf "%s loops at %s\n", $e, $cv{$e};
	}
    }

    unless ($skipped || keys %cc) {
	$skipped++;
	my $skip = lcm(values %cv);
	my $skip_count = int(1000000000000 / ($solution1 * $skip));

	printf "skip: %s, to: %s\n", $skip, $skip_count;

	%have = ( ORE => 1000000000000 - $solution1 * $skip_count * $skip);
	$prod{FUEL} = $skip_count * $skip;

	printf "%s\n", Data::Dumper->Dump([\%prod],[qw(prod)]);
	printf "%s\n", Data::Dumper->Dump([\%used],[qw(used)]);
	printf "%s\n", Data::Dumper->Dump([\%have],[qw(have)]);
	printf "\n";

    }


    $need{FUEL} += 1;

    while (keys %need) {

	for my $e (sort { $need{$b} <=> $need{$a}} keys %need) {
	    my $need = delete $need{$e};
	    if ($e eq 'ORE') {
		$have{ORE} -= $need;
		next;
	    }

	    my($in) = $react{$e}{in};
	    my($out) = $react{$e}{out};

	    while ($have{$e} < $need) {
		$have{$e} += $out;
		$prod{$e} += $out;
		for my $i (@$in) {
		    $need{$i->{element}} += $i->{amount};
		}
	    }
	    $have{$e} -= $need;
	}
    }
    last if $have{ORE} < 0;
}

$solution2 = $prod{FUEL};

printf "%s\n", Data::Dumper->Dump([\%prod],[qw(prod)]);
printf "%s\n", Data::Dumper->Dump([\%used],[qw(used)]);
printf "%s\n", Data::Dumper->Dump([\%have],[qw(have)]);
printf "\n";


printf "Solution 2: %s\n", join " ", $solution2;
