#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

my $data;
my $rules;

while (<>) {
    chomp;
    if (/^value (\d+) goes to bot (\d+)$/) {
	push @{$data->{bot}{$2}}, $1;
    }
    elsif (/^bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)$/) {
	warn "seen rule $1\n" if $rules->[$1];
	$rules->[$1] = [ $2 => $3, $4 => $5 ];
    }
    else {
	die "Unparsable:$.:$_\n";
    }
}

my $ans1;
loop:
while (my @bots = grep { @{$data->{bot}{$_}} > 1 } keys %{$data->{bot}}) {
    for my $bot (@bots) {
	my($low,$high) = sort {$a<=>$b} splice @{$data->{bot}{$bot}}, 0, 2;
	if ($low == 17 && $high == 61) {
	    $ans1 = $bot;
	}
	my($l_type,$l_idx,$h_type,$h_idx) = @{$rules->[$bot]};
	push @{$data->{$l_type}{$l_idx}}, $low;
	push @{$data->{$h_type}{$h_idx}}, $high;
    }
}

printf "Solution 1: comparing 17 and 61 = bot %d\n", $ans1;

# print Dumper $data->{output};

printf "Solution 2: P(output 0..2) = %d\n",
  $data->{output}{0}[0] *
  $data->{output}{1}[0] *
  $data->{output}{2}[0];
