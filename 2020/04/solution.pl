#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2020 by Peder Stray <peder@wintermute>
#

use strict;

my %fields =
  (
   byr => [ 1, "Birth Year", qr/^(19[2-9]\d|200[0-2])$/ ],
   iyr => [ 1, "Issue Year", qr/^(201\d|2020)$/ ],
   eyr => [ 1, "Expiration Year", qr/^(202\d|2030)$/ ],
   hgt => [ 1, "Height", qr/^((?:1[5-8]\d|19[0-3])cm|(?:59|6\d|7[0-6])in)$/ ],
   hcl => [ 1, "Hair Color", qr/^#[[:xdigit:]]{6}$/ ],
   ecl => [ 1, "Eye Color", qr/^(amb|blu|brn|gry|grn|hzl|oth)$/ ],
   pid => [ 1, "Passport ID", qr/^\d{9}$/ ],
   cid => [ 0, "Country ID" ],
  );

use Data::Dumper;

my @required = grep { $fields{$_}[0] } keys %fields;

my $solution1 = 0;
my $solution2 = 0;

my $data = {};
while (<>) {
    my $fields = 0;
    while (s/(\S+):(\S+)//) {
	$data->{$1} = $2;
	$fields++;
    }
    if (!$fields || eof) {
	my $d = $data;
	$data = {};
	my $valid1 = 1;
	my $valid2 = 1;
	for my $key (@required) {
	    unless (exists $d->{$key}) {
		$valid1 = 0;
		last;
	    }
	    $valid2 = 0 unless $d->{$key} =~ $fields{$key}[2];
	}
	next unless $valid1;
	$solution1++;
	next unless $valid2;
	$solution2++;
    }
}

printf "Solution1: %d\n", $solution1;
printf "Solution2: %d\n", $solution2;
