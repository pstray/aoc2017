#! /usr/bin/perl

use strict;
use Data::Dumper;
$Data::Dumper::Sortkeys = $Data::Dumper::Ident = 1;

@ARGV = qw(input) unless @ARGV;

my %pipes;

while (<>) {
    chomp;
    s/\s*<->\s*/, /;
    my($from,@pipes) = split /\s*,\s*/;
    for my $to (@pipes) {
	$pipes{$from}{$to}++;
	$pipes{$to}{$from}++;
    }
}

sub in_group {
    my($pid,$pipes) = @_;
    my $size = 1;
    my $p = delete $pipes{$pid};
    return 0 unless $p;
    for my $p (keys %$p) {
	$size += in_group($p,$pipes);
    }
    return $size;
}

my $members = in_group(0,\%pipes);

printf "Solution 1: %d members\n", $members;

my $groups = 1;

while (my($next) = keys %pipes) {
    $groups++;
    # printf "  group %d: %d members\n", $groups,
    in_group($next, \%pipes);
}

printf "Solution 2: %d groups total\n", $groups;
