#! /usr/bin/perl

use strict;
use Data::Dumper;
$Data::Dumper::Sortkeys = $Data::Dumper::Ident = 1;

@ARGV = qw(input) unless @ARGV;

my $input = do { local $/ = undef; <>; };
chomp $input;

my @path = split ",", $input;

my $pos_x = 0;
my $pos_y = 0;

for my $dir (@path) {
    if ($dir eq 'se') {
	$pos_x++;
	$pos_y--;
    }
    elsif ($dir eq 'ne') {
	$pos_x++;
	$pos_y++;
    }
    elsif ($dir eq 'n') {
	$pos_y += 2;
    }
    elsif ($dir eq 'nw') {
	$pos_x--;
	$pos_y++;
    }
    elsif ($dir eq 's') {
	$pos_y -= 2;
    }
    elsif ($dir eq 'sw') {
	$pos_x--;
	$pos_y--;
    }
    else {
	die "unhandled dir [$dir]\n";
    }
}

my $steps = abs($x_dir);


__END__

printf "Solution 1: %d steps\n", $steps;

my $groups = 1;

while (my($next) = keys %pipes) {
    $groups++;
    # printf "  group %d: %d members\n", $groups,
    in_group($next, \%pipes);
}

printf "Solution 2: %d groups total\n", $groups;
