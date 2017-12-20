#! /usr/bin/perl

use strict;

use Data::Dumper;

@ARGV = qw(input) unless @ARGV;

my %input;

while (<>) {
    if (/Generator (.) starts with (\d+)/) {
	$input{$1} = $2;
    }
}


my($val_A, $val_B) = @input{qw(A B)};

my $fact_A = 16807;
my $fact_B = 48271;

my $divider = 2147483647;

my $same16 = 0;

for (1 .. 40_000_000) {
    do {
	$val_A = ($val_A * $fact_A) % $divider;
    } while ($val_A & 3);
    do {
    } while ();
    $val_B = ($val_B * $fact_B) % $divider;
    $same16++ if ($val_A & 0xFFFF) == ($val_B & 0xFFFF);
}

printf "Solution 1: %d\n", $same16;

($val_A, $val_B) = @input{qw(A B)};
$same16 = 0;

for (1 .. 5_000_000) {
    do {
	$val_A = ($val_A * $fact_A) % $divider;
    } while ($val_A & 3);
    do {
	$val_B = ($val_B * $fact_B) % $divider;
    } while ($val_B & 7);
    $same16++ if ($val_A & 0xFFFF) == ($val_B & 0xFFFF);
}

printf "Solution 2: %d\n", $same16;
