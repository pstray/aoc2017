#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

my $f = 10551319;

my @f1 = (qw(1 23 79 5807));
my @f2 = map { $f/$_ } @f1;

my $s = join "+", @f1, @f2;

printf "Solution 2: %s = %d\n", $s, eval $s;
