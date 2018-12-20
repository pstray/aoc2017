#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

my $data = do { local $/ = undef; <>};
$data =~ s/\s+//g;

my $input = $data;
my $output = "";
while (length $input) {
    if ($input =~ s/^\((\d+)x(\d+)\)//) {
	$output .= substr($input,0,$1,'') x $2;
    }
    else {
	$output .= substr($input,0,1,'');
    }
}

printf "Solution 1: length of output = %d\n", length $output;

sub decode2 {
    my($str) = @_;
    my $len = 0;
    # print "Decoding [$str]\n";
    while (length $str) {
	if ($str =~ s/^\((?<sl>\d+)x(?<m>\d+)\)//) {
	    my($sl,$m) = @+{qw(sl m)};
	    my $d = decode2(substr($str,0,$sl,''));
	    #printf "Adding %d * %d = %d\n", $m, $d, $m*$d;
	    $len += $m * $d;
	}
	else {
	    $str =~ s/^([^(]+)//;
	    my $d = length $1;
	    #printf "Adding %d\n", $d;
	    $len += $d;
	}
    }
    return $len;
}

printf "Solution 2: length of v2 output = %d\n", decode2($data);
