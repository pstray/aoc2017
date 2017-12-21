#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my @lengths = split ",", do { local $/ = undef; <>; };
my @list = (0 .. 255);

my $pos = 0;
my $skip = 0;

#printf "%s\n", join " ", map { $_==$pos ? "($list[$_])" : " $list[$_] " } 0 .. @list-1;
for my $length (@lengths) {
    die "invalid length $length\n" if $length > @list;

    push @list, splice @list, 0, $pos;
    splice @list, 0, $length, reverse @list[0 .. $length-1];
    unshift @list, splice @list, -$pos;
    
    $pos += $length + $skip;
    $pos %= 0+@list;
    $skip++;

    #printf "%s\n", join " ", map { $_==$pos ? "($list[$_])" : " $list[$_] " } 0 .. @list-1;

}

printf "Solution 1: %d\n", $list[0]*$list[1];
