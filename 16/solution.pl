#! /usr/bin/perl

use strict;

use Data::Dumper;

@ARGV = qw(input) unless @ARGV;

my $input = do { local $/ = undef; <>; };
chomp $input;

my $programs = join "", 'a' .. 'p';

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


printf "$programs\n";

