#! /usr/bin/perl
#
# Copyright (C) 2020 by Peder Stray <peder@ninja.no>
#

use strict;

use Data::Dumper;
use FindBin;
eval { require "$FindBin::Bin/../../lib/common.pl"; };

my $solution1 = 0;
my $solution2 = 0;

my @program;

# $/ = "";
while (<>) {
    if (/^(acc|jmp|nop)\s+([+-]\d+)$/) {
	push @program, [ $1, $2 ];
    }
    else {
	die "unknown data: $_\n";
    }
}

sub run {
    my($code) = @_;
    my $acc = 0;
    my $ip = 0;
    my %seen;
    my $looping = 0;

    #printf "%s %+d\n", @$_ for @$code;

    while ($ip < @$code) {
	$looping++ if $seen{$ip}++;
	if ($looping) {
	    #print "loop: \@$ip\n";
	    last;
	}
	my($op,$arg) = @{$code->[$ip++]};
	if ($op eq 'acc') {
	    $acc += $arg;
	    #print "$ip: acc($arg) : $acc\n";
	}
	elsif ($op eq 'jmp') {
	    $ip += $arg-1;
	}
	elsif ($op eq 'nop') {
	    # nothing
	}
    }
    #printf "\n";
    return wantarray ? ($acc,$looping) : $acc;
}

$solution1 = run(\@program);

printf "Solution1: %s\n", $solution1;

for my $i (0 .. @program-1) {
    my $loop = 1;
    if ($program[$i][0] eq 'nop') {
	local $program[$i][0] = 'jmp';
	#print "repl nop \@$i\n";
	($solution2,$loop) = run(\@program);
    }
    elsif ($program[$i][0] eq 'jmp') {
	local $program[$i][0] = 'nop';
	#print "repl jmp \@$i\n";
	($solution2,$loop) = run(\@program);
    }
    last unless $loop;
}

printf "Solution2: %s\n", $solution2;
