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

my @ops;
my($rip);

while (<>) {
    chomp;
    if (/^#ip\s+(\d+)/) {
	$rip = $1;
    }
    elsif (/^(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$/) {
	push @ops, [ $1, $2, $3, $4 ];
    }
    else {
	warn "Unparsable input:$.: $_\n";
    }
}

$| = 1;

sub run {
    my($rip,$reg,$code) = @_;
    my(%op_seen);
    my(%ip_seen);
    my($loop);

    $reg->[$rip] = 0;
    $loop = 0;
    while (1) {
	my $ip = $reg->[$rip];
	last if $ip < 0;
	last if $ip > @$code;

	my($op,$ra,$rb,$rc) = @{$code->[$ip]};

	# $op_seen{$op}++;

	printf "ip=%d [%s] %s %d %d %d", $ip, join(", ", @$reg), $op, $ra, $rb, $rc
          if $rc == 0 || $ip_seen{$ip}<10;

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

	printf " [%s]\n", join(", ", @$reg)
	  if $rc == 0 || $ip_seen{$ip}<10;

	$ip_seen{$ip}++;

	$reg->[$rip]++;

	if ($ip == 1) {
	    printf "Patching program...\n";
	    %ip_seen = ();
	    my @new_code = (
			    [ gtrr => 2, 1, 7 ],
			    [ addr => $rip, 7, $rip ],
			    [ addi => $rip, 4, $rip ],
			   );

	    splice @$code, 8, 0, @new_code;
	}
	#printf "%5d\r", $loop++;
    }

    #for my $op (sort {$op_seen{$b} <=> $op_seen{$a}} keys %op_seen) {
    #printf "%s: %5d\n", $op, $op_seen{$op};
    #}

    return $reg;
}

if ($part1) {
    printf "Running 1...\n";
    my $reg = run($rip,[],\@ops);
    printf "Solution 1: Register 0 contains = %d\n", $reg->[0];
}

if ($part2) {
    printf "Running 2...\n";
    my $reg = run($rip,[1],\@ops);
    printf "Solution 2: Register 0 contains = %d\n", $reg->[0];
}
