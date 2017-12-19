#! /usr/bin/perl

use strict;

use Data::Dumper;
use Time::HiRes qw(sleep);

$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent = 0;

@ARGV = qw(input) unless @ARGV;

my @code;
while (<>) {
    chomp;
    push @code, [ split " ", $_ ];
}

my $ip = 0;
my %reg;
my $freq = 0;

while ($ip < @code) {
    my($op,$x,$y) = @{$code[$ip]};
    my $inc = 1;

    $y = $reg{$y} ||= 0 if $y =~ /[^0-9-]/;
    
    if ($op eq 'set') {
	$reg{$x} = $y;
    }
    elsif ($op eq 'mul') {
	$reg{$x} *= $y;
    }
    elsif ($op eq 'jgz') {
	$x = $reg{$x} ||= 0 if $x =~ /[^0-9-]/;
	if ($x>0) {
	    $inc = $y;
	}
    }
    elsif ($op eq 'add') {
	$reg{$x} += $y;
    }
    elsif ($op eq 'mod') {
	$reg{$x} %= $y;
    }
    elsif ($op eq 'snd') {
	$freq = $reg{$x};
    }
    elsif ($op eq 'rcv') {
	if ($reg{$x} != 0) {
	    printf "Solution 1: %d\n", $freq;
	    last;
	    $reg{$x} eq $freq;
	}
    }
    else {
	die "unknown op [$op] $x $y ($code[$ip][2])\n", join " ", $op, $x, $y;
    }
    $ip += $inc;
}

# the Real Duet;

my @prog = map { { ip => 0, q => [], r => { p => $_ }}} 0..1;
my $iter = 0;

duet:
while (1) {
    # printf "OP[%5d]: \n", $iter++;
    for my $pid (0 .. 1) {
	my $p = $prog[$pid];
	unless ($p->{ip} < @code) {
	    $p->{terminated} = 1;
	    next;
	}
	my($op,$x,$y) = @{$code[$p->{ip}]};

	# printf "%3d: %-3s %s %3s\n", $p->{ip}, @{$code[$p->{ip}]};

	my $inc = 1;
	$y = $p->{r}{$y} ||= 0 if $y =~ /[^0-9-]/;
	
	if ($op eq 'set') {
	    $p->{r}{$x} = $y;
	}
	elsif ($op eq 'mul') {
	    $p->{r}{$x} *= $y;
	}
	elsif ($op eq 'jgz') {
	    $x = $p->{r}{$x} ||= 0 if $x =~ /[^0-9-]/;
	    if ($x>0) {
		$inc = $y;
	    }
	}
	elsif ($op eq 'add') {
	    $p->{r}{$x} += $y;
	}
	elsif ($op eq 'mod') {
	    $p->{r}{$x} %= $y;
	}
	elsif ($op eq 'snd') {
	    push @{$prog[$pid?0:1]{q}}, $p->{r}{$x};
	    $p->{sends}++;
	}
	elsif ($op eq 'rcv') {
	    if ($p->{sleep} = !@{$p->{q}}) {
		$inc = 0;
	    }
	    else {
		$p->{r}{$x} = shift @{$p->{q}}
	    }
	}
	else {
	    die "unknown op [$op] $x $y ($code[$ip][2])\n", join " ", $op, $x, $y;
	}
	$p->{ip} += $inc;

	#printf "%s\n\n", join "\n", Dumper(@prog);
    }
    # print "\n";

    #sleep .1;
    
    if (@prog == grep { $_->{sleep} } @prog) {
	warn "Deadlock reached\n";
	last duet;
    }
    if (@prog == grep { $_->{terminated} } @prog) {
	warn "All pids terminated\n";
	last duet;
    }
}

printf "Solution 2: %d\n", $prog[1]{sends};




