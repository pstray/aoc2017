#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;


my @ops;
my($ipr,$ip);
my @reg = (0)x6;

while (<>) {
    chomp;
    if (/^#ip\s+(\d+)/) {
	$ipr = $1;
    }
    elsif (/^(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$/) {
	push @ops, [ $1, $2, $3, $4 ];
    }
    else {
	warn "Unparsable input:$.: $_\n";
    }
}

$ip = 0;
@reg = ();

while (1) {
    if ($ip < 0 || $ip >= @ops) {
	last;
    }
    $reg[$ipr] = $ip;
    my($op,$ra,$rb,$rc) = @{$ops[$ip]};

    # printf "ip=%d [%s] %s %d %d %d", $ip, join(", ", @reg), $op, $ra, $rb, $rc;
    
    if ($op eq "addr") { $reg[$rc] = ($reg[$ra] + $reg[$rb]); }
    elsif ($op eq "addi") { $reg[$rc] = ($reg[$ra] + $rb); }
    elsif ($op eq "mulr") { $reg[$rc] = ($reg[$ra] * $reg[$rb]); }
    elsif ($op eq "muli") { $reg[$rc] = ($reg[$ra] * $rb); }
    elsif ($op eq "banr") { $reg[$rc] = ($reg[$ra] & $reg[$rb]); }
    elsif ($op eq "bani") { $reg[$rc] = ($reg[$ra] & $rb); }
    elsif ($op eq "borr") { $reg[$rc] = ($reg[$ra] | $reg[$rb]); }
    elsif ($op eq "bori") { $reg[$rc] = ($reg[$ra] | $rb); }
    elsif ($op eq "setr") { $reg[$rc] = $reg[$ra]; }
    elsif ($op eq "seti") { $reg[$rc] = $ra; }
    elsif ($op eq "gtir") { $reg[$rc] = ($ra > $reg[$rb] ? 1 : 0); }
    elsif ($op eq "gtri") { $reg[$rc] = ($reg[$ra] > $rb ? 1 : 0); }
    elsif ($op eq "gtrr") { $reg[$rc] = ($reg[$ra] > $reg[$rb] ? 1 : 0); }
    elsif ($op eq "eqir") { $reg[$rc] = ($ra == $reg[$rb] ? 1 : 0); }
    elsif ($op eq "eqri") { $reg[$rc] = ($reg[$ra] == $rb ? 1 : 0); }
    elsif ($op eq "eqrr") { $reg[$rc] = ($reg[$ra] == $reg[$rb] ? 1 : 0); }
    else {
	die "Unknown op $op at $ip\n";
    }

    # printf " [%s]\n", join(", ", @reg);

    $ip = $reg[$ipr];
    $ip++;
}

printf "Solution 1: Register 0 contains = %d\n", $reg[0];

__END__
@reg=();
$reg[0] = 1;
$ip = 0;

$| = 1;

while (1) {
    if ($ip < 0 || $ip >= @ops) {
	last;
    }
    $reg[$ipr] = $ip;
    my($op,$ra,$rb,$rc) = @{$ops[$ip]};

    # printf "ip=%d [%s] %s %d %d %d", $ip, join(", ", @reg), $op, $ra, $rb, $rc;

    if ($op eq "addr") { $reg[$rc] = ($reg[$ra] + $reg[$rb]); }
    elsif ($op eq "addi") { $reg[$rc] = ($reg[$ra] + $rb); }
    elsif ($op eq "mulr") { $reg[$rc] = ($reg[$ra] * $reg[$rb]); }
    elsif ($op eq "muli") { $reg[$rc] = ($reg[$ra] * $rb); }
    elsif ($op eq "banr") { $reg[$rc] = ($reg[$ra] & $reg[$rb]); }
    elsif ($op eq "bani") { $reg[$rc] = ($reg[$ra] & $rb); }
    elsif ($op eq "borr") { $reg[$rc] = ($reg[$ra] | $reg[$rb]); }
    elsif ($op eq "bori") { $reg[$rc] = ($reg[$ra] | $rb); }
    elsif ($op eq "setr") { $reg[$rc] = $reg[$ra]; }
    elsif ($op eq "seti") { $reg[$rc] = $ra; }
    elsif ($op eq "gtir") { $reg[$rc] = ($ra > $reg[$rb] ? 1 : 0); }
    elsif ($op eq "gtri") { $reg[$rc] = ($reg[$ra] > $rb ? 1 : 0); }
    elsif ($op eq "gtrr") { $reg[$rc] = ($reg[$ra] > $reg[$rb] ? 1 : 0); }
    elsif ($op eq "eqir") { $reg[$rc] = ($ra == $reg[$rb] ? 1 : 0); }
    elsif ($op eq "eqri") { $reg[$rc] = ($reg[$ra] == $rb ? 1 : 0); }
    elsif ($op eq "eqrr") { $reg[$rc] = ($reg[$ra] == $reg[$rb] ? 1 : 0); }
    else {
	die "Unknown op $op at $ip\n";
    }

    # printf " [%s]\n", join(", ", @reg);

    $ip = $reg[$ipr];
    $ip++;
}

printf "Solution 2: Register 0 contains = %d\n", $reg[0];
