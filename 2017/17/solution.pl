#! /usr/bin/perl

use strict;

use Data::Dumper;

@ARGV = qw(input) unless @ARGV;

my $input = do { local $/ = undef; <>; };
chomp $input;

my @buffer = (0);
my $pos = 0;

for my $val (1 .. 2017) {
    $pos = ($pos + $input) % @buffer;
    splice @buffer, ++$pos, 0, $val;
    # printf "%s\n", join " ", map { $_ == $pos ? "($buffer[$_])" : $buffer[$_] } 0 .. @buffer-1;
}

printf "Solution 1: %s\n", join " ",
  map { $_ ? $buffer[$pos+$_] : "($buffer[$pos])" } -3 .. 3;

my $buf_size = 1;
my $after_null;

for my $val (1 .. 50000000) {
    $pos = ($pos + $input) % $buf_size;
    $pos++;
    $buf_size++;
    $after_null = $val if $pos == 1;
}

printf "Solution 2: %s\n", $after_null;
