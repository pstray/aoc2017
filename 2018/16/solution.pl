#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

my @before;
my @after;
my @ops;

my @op_str = qw(addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr);

my @op_bitmap = ("1"x16) x 16;
my $solution1 = 0;
my $samples = 0;
 
while (<>) {
    if (/^Before:\s*\[(\d+),\s*(\d+),\s*(\d+),\s*(\d+)\]/) {
	@before = map {0+$_} $1, $2, $3, $4;
    }
    elsif (/^After:\s*\[(\d+),\s*(\d+),\s*(\d+),\s*(\d+)\]/) {
	@after = map {0+$_} $1, $2, $3, $4;

	my($op,$ra,$rb,$rc) = @{$ops[-1]};

	# print "B[@before] A[@after] $op $ra $rb $rc\n";

	my @same = map { $before[$_] == $after[$_] || $_ == $rc } 0..3;
	unless ("@same" eq "1 1 1 1") {
	    print "Input error line $.: B[@before] A[@after] $op $ra $rb $rc [@same]\n";
	}

	$samples++;

	my %opc;

	$opc{addr}++ if $after[$rc] == ($before[$ra] + $before[$rb]);
	$opc{addi}++ if $after[$rc] == ($before[$ra] + $rb);

	$opc{mulr}++ if $after[$rc] == ($before[$ra] * $before[$rb]);
	$opc{muli}++ if $after[$rc] == ($before[$ra] * $rb);

	$opc{banr}++ if $after[$rc] == ($before[$ra] & $before[$rb]);
	$opc{bani}++ if $after[$rc] == ($before[$ra] & $rb);

	$opc{borr}++ if $after[$rc] == ($before[$ra] | $before[$rb]);
	$opc{bori}++ if $after[$rc] == ($before[$ra] | $rb);

	$opc{setr}++ if $after[$rc] == $before[$ra];
	$opc{seti}++ if $after[$rc] == $ra;

	$opc{gtir}++ if $after[$rc] == ($ra > $before[$rb] ? 1 : 0);
	$opc{gtri}++ if $after[$rc] == ($before[$ra] > $rb ? 1 : 0);
	$opc{gtrr}++ if $after[$rc] == ($before[$ra] > $before[$rb] ? 1 : 0);

	$opc{eqir}++ if $after[$rc] == ($ra == $before[$rb] ? 1 : 0);
	$opc{eqri}++ if $after[$rc] == ($before[$ra] == $rb ? 1 : 0);
	$opc{eqrr}++ if $after[$rc] == ($before[$ra] == $before[$rb] ? 1 : 0);

	# printf("%s (%d == %d[%d] op %d[%d]) behaves as:\n\t%s\n",
	#        $op,
	#        $after[$rc], $ra, $before[$ra], $rb, $before[$rb],
	#        join(" ", sort keys %opc)
	#       );
	
	if (keys(%opc) >= 3) {
	    $solution1++;
	}
	
	my $op_bmap = join "", map { $opc{$_} ? 1 : 0 } @op_str;
	#printf "\t%s\n", $op_bmap;
	$op_bitmap[$op] &= $op_bmap;
    }
    elsif (/^(\d+(?:\s+\d+)*)/) {
	push @ops, [ map {0+$_} split " ", $1 ];
    }
    elsif (/^\s*$/) {
	@ops = ();
    }
    
}

printf "Solution 1: opcodes behaving as 3+ = %d of %d samples\n",
  $solution1, $samples;

my @op_map;
my $unknown = 16;
while ($unknown>0) {
    #printf "Unknowns: %d\n", $unknown;
    my $l_unknown = $unknown;
    for my $op (grep {!$op_map[$_]} 0..15) {
	my $bmap = $op_bitmap[$op];
	my $count1 = () = $bmap =~ /1/g;
	#printf "o:%s %d\n", $bmap, $count1;
	if ($count1 == 1) {
	    $unknown--;
	    #printf "Found %d = %s\n", $op,
	    $op_map[$op] = $op_str[index $bmap, "1"];
	    for my $oo (0..15) {
		my $nmap = $bmap;
		$nmap =~ y/01/10/;
		$op_bitmap[$oo] &= $nmap;
	    }
	}
    }
    die "no reduction possible" if $unknown == $l_unknown;
}

#printf "Program size: %d\n", 0+@ops;

my @reg = (0)x4;
for my $op (@ops) {
    my($opn,$ra,$rb,$rc) = @$op;
    $op = $op_map[$opn];
    # printf "%s %d %d %d\n", $op, $ra, $rb, $rc;

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
	die "Unknown op $opn";
    }
    
}

printf "Solution 2: register 0 contains %d\n", $reg[0];
