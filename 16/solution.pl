#! /usr/bin/perl

use strict;

use Data::Dumper;

@ARGV = qw(input) unless @ARGV;

my $input = do { local $/ = undef; <>; };
chomp $input;
my $programs = join "", 'a' .. 'p';
my %cache = ( $programs => 1 );
my @cache = ($programs);

my $max_iter = 1_000_000_000;

for (1 .. $max_iter) {
    for my $move (split ",", $input) {
	if ($move =~ m,^s(\d+)$,) {
	    substr $programs, 0, 0, substr $programs, -$1, $1, '';
	}
	elsif ($move =~ m,^x(\d+)/(\d+),) {
	    (substr($programs,$1,1),substr($programs,$2,1)) =
	      (substr($programs,$2,1),substr($programs,$1,1));
	}
	elsif ($move =~ m,^p(.)/(.),) {
	    my $p1 = index $programs, $1;
	    my $p2 = index $programs, $2;
	    (substr($programs,$p1,1),substr($programs,$p2,1)) =
	      (substr($programs,$p2,1),substr($programs,$p1,1));
	}
	else {
	    die "Unhandled move [$move]\n";
	}
    }
    last if $cache{$programs}++;
    push @cache, $programs;
}

print Dumper \@cache;

printf "Solution 1: %s\n", $cache[1];
printf "Cycle length: %d\n", 0+@cache;

my $end_pos = ($max_iter) % @cache;
printf "End pos: %s\n", $end_pos;

printf "Solution 2: %s\n", $cache[$end_pos];



