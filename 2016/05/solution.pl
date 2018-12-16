#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;
use Digest::MD5 qw(md5_hex);

while (<>) {
    chomp;
    my $door_id = $_;
    my $index = 0;
    my $pass1 = "";
    my $pass2 = "________";
    while (length($pass1) < 8) {
	my $hash = md5_hex($door_id.$index++);
	if ($hash =~ /^00000(.)/) {
	    $pass1 .= $1;
	}
	if ($hash =~ /^00000([0-7])(.)/) {
	    substr($pass2,$1,1) = $2 if substr($pass2,$1,1) eq '_';
	}
    }
    printf "Solution 1: pass1 is %s\n", $pass1;
    while ($pass2 =~ /_/) {
	my $hash = md5_hex($door_id.$index++);
	if ($hash =~ /^00000([0-7])(.)/) {
	    substr($pass2,$1,1) = $2 if substr($pass2,$1,1) eq '_';
	}
    }
    printf "Solution 2: pass2 is %s\n", $pass2;
}
