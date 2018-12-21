#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;
use Getopt::Long;

my $part1;
my $part2;

GetOptions('1|part1' => \$part1,
	   '2|part2' => \$part2,
	  );

unless ($part1 || $part2) {
    $part1 = 1;
}

my $code;
my($rip);

while (<>) {
    chomp;
    if (/^#ip\s+(\d+)/) {
	$rip = $1;
    }
    elsif (/^(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$/) {
	push @$code, [ $1, 0+$2, 0+$3, 0+$4 ];
    }
    else {
	warn "Unparsable input:$.: $_\n";
    }
}

$| = 1;

my $reg = [(0)x6];

my(%ip_seen);
my(%r5_seen);
my $last_r5;
my $loop;

my $ans1;
my $ans2;

$reg->[$rip] = 0;
$loop = 0;
loop:
while (1) {
    my $ip = $reg->[$rip];
    last if $ip < 0;
    last if $ip >= @$code;

    my($op,$ra,$rb,$rc) = @{$code->[$ip]};

    if ($ip == 28) {
	# printf "ip=%d [%s] %s %d %d %d\n", $ip, join(", ", @$reg), $op, $ra, $rb, $rc;
	printf "%5d r5=%d\n", $loop, $reg->[5]
	  unless $loop++ % 10;
	unless ($ans1) {
	    $ans1 = $reg->[5];
	    printf "Solution 1: Register 0 should contain = %d\n", $ans1;
	    last loop unless $part2;
	}
	if ($r5_seen{$reg->[5]}++) {
	    $ans2 = $last_r5;
	    last loop;
	}
	$last_r5 = $reg->[5];
    }

    if ($op eq "addr") { $reg->[$rc] = ($reg->[$ra] + $reg->[$rb]); }
    elsif ($op eq "addi") { $reg->[$rc] = ($reg->[$ra] + $rb); }
    elsif ($op eq "seti") { $reg->[$rc] = $ra; }
    elsif ($op eq "gtrr") { $reg->[$rc] = ($reg->[$ra] > $reg->[$rb] ? 1 : 0); }
    elsif ($op eq "mulr") { $reg->[$rc] = ($reg->[$ra] * $reg->[$rb]); }
    elsif ($op eq "eqrr") { $reg->[$rc] = ($reg->[$ra] == $reg->[$rb] ? 1 : 0); }
    elsif ($op eq "muli") { $reg->[$rc] = ($reg->[$ra] * $rb); }

    elsif ($op eq "banr") { $reg->[$rc] = ($reg->[$ra] & $reg->[$rb]); }
    elsif ($op eq "bani") { $reg->[$rc] = ($reg->[$ra] & $rb); }
    elsif ($op eq "borr") { $reg->[$rc] = ($reg->[$ra] | $reg->[$rb]); }
    elsif ($op eq "bori") { $reg->[$rc] = ($reg->[$ra] | $rb); }
    elsif ($op eq "setr") { $reg->[$rc] = $reg->[$ra]; }
    elsif ($op eq "gtir") { $reg->[$rc] = ($ra > $reg->[$rb] ? 1 : 0); }
    elsif ($op eq "gtri") { $reg->[$rc] = ($reg->[$ra] > $rb ? 1 : 0); }
    elsif ($op eq "eqir") { $reg->[$rc] = ($ra == $reg->[$rb] ? 1 : 0); }
    elsif ($op eq "eqri") { $reg->[$rc] = ($reg->[$ra] == $rb ? 1 : 0); }
    else {
	warn "Unknown op $op at $ip\n";
	return;
    }

    # $ip_seen{$ip}++;

    $reg->[$rip]++;

    #printf "%5d\r", $loop++;
}

printf "Solution 2: Register 0 should contain = %d\n", $ans2;
