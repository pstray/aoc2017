#! /usr/bin/perl

use strict;

@ARGV = qw(input) unless @ARGV;

my %prog;

while (<>) {
    chomp;
    if (my($prog,$weight,$kids) = m,^(\S+)\s+\((\d+)\)(?:\s*->\s+(.*))?,) {
	my @kids = split /\s*,\s*/, $kids;
	$prog{$prog}{w} = $weight;
	$prog{$prog}{kids} = [@kids];
	for my $kid (@kids) {
	    $prog{$kid}{kid}++;
	}
    }
    else {
	die "unhandled input [$_]\n";
    }
}

my($top,@others) = grep { !$prog{$_}{kid} } keys %prog;

printf "Solution 1: top = '%s'\n", $top;
if (@others) {
    printf "  ... but i found others: %s\n", join ", ", @others;
}

sub weight {
    my($prog) = @_;
    my $w = $prog{$prog}{w};

    my %kid_weight;

    for my $kid (@{$prog{$prog}{kids}}) {
	my $kw = weight($kid);
	push @{$kid_weight{$kw}}, $kid;
	$w += $kw;
    }

    my @weights = sort {$a<=>$b} keys %kid_weight;
    if (@weights>1) {
	my($off_weight) = grep { @{$kid_weight{$_}}==1 } keys %kid_weight;
	my($off_name)   = @{$kid_weight{$off_weight}};
	my($corr_weight) = grep { $_ != $off_weight } keys %kid_weight;
	printf "Solution 2: '%s' should be %d\n",
	  $off_name,
	  $prog{$off_name}{w} + $corr_weight - $off_weight;
	$w += $corr_weight - $off_weight;
    }

    $prog{$prog}{_tw} = $w;
}

weight($top);
