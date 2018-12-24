#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;
use Data::Dumper;
$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

use Getopt::Long;

my $part = 1;
GetOptions('1|part1' => sub { $part = 1 },
	   '2|part2' => sub { $part = 2 },
	  );

my %groups;
my $army = '';
while (<>) {
    chomp;

    if (/^(Immune System|Infection):$/) {
	$army = $1;
    }
    elsif (/^(?<units>\d+) units each with (?<hp>\d+) hit points(?: \((?<opts>.*?)\))? with an attack that does (?<ad>\d+) (?<at>[a-z]+) damage at initiative (?<initiative>\d+)$/) {
	my $group = {%+};
	$group->{army} = $army;
	$group->{group} = 1+grep { $groups{$_}{army} eq $army } keys %groups;
	$group->{orig} = { map { $_ => $group->{$_} } qw(units ad) };
	my $id = $group->{id} = $group->{army}."-".$group->{group};
	$groups{$id} = $group;
	my (@opts) = split /\s*;\s*/, delete $group->{opts};
	for (@opts) {
	    if (/^immune to ([a-z, ]+)$/) {
		for my $i (split /\s*,\s*/, $1) {
		    $group->{immune}{$i}++;
		}
	    }
	    elsif (/^weak to ([a-z, ]+)$/) {
		for my $i (split /\s*,\s*/, $1) {
		    $group->{weak}{$i}++;
		}
	    }
	    else {
		die "Unparsable options:$.: $_\n";
	    }
	}
	print Dumper $group;
    }
    elsif (/^\s*$/) {
	# nothing
    }
    else {
	die "Unparsable input:$.: $_\n";
    }
}

my $boost_army = "Immune System";
my $boost = 0;
my $boost_low = 0;
my $boost_high = 1;

while (1) {

    for my $g (values %groups) {
	for my $k (keys %{$g->{orig}}) {
	    $g->{$k} = $g->{orig}{$k}
	}
	next unless $g->{army} eq $boost_army;
	$g->{ad} += $boost;
    }

    my $round;
    my %alive;
    while (1) {
	printf "==== Round %d (boost %d) ====\n\n", ++$round, $boost;

	my @groups = grep { $_->{units}>0 } values %groups;
	for my $g (sort {$a->{army} cmp $b->{army} || $a->{group}<=>$b->{group}}
		   @groups) {
	    printf("%s %d contains %d units\n",
		   $g->{army}, $g->{group}, $g->{units},
		  ) if $part == 1;
	    $g->{ep} = $g->{units}*$g->{ad};
	    for my $key (keys %$g) {
		delete $g->{$key} if $key =~ /^_/;
	    }

	}
	printf "\n" if $part == 1;

	@groups = sort {$b->{ep} <=> $a->{ep}
			  || $b->{initiative}<=>$a->{initiative}
		      } @groups;

	# Select targets
	for my $attacker (@groups) {
	    # printf Dumper $attacker;
	    my @defenders = grep { $_->{army} ne $attacker->{army} && !$_->{_marked}} @groups;
	    for my $def (@defenders) {
		my $damage = $attacker->{ep};
		my $dmul   = 1;
		if ($def->{immune}{$attacker->{at}}) {
		    $dmul = 0;
		}
		elsif ($def->{weak}{$attacker->{at}}) {
		    $dmul = 2;
		}
		$damage *= $dmul;
		$def->{_dmul} = $dmul;
		$def->{_damage} = $damage;
		printf("%s group %d would deal defending group %d %d damage\n",
		       $attacker->{army}, $attacker->{group},
		       $def->{group}, $damage,
		      ) if $part == 1;
	    }
	    my($target) = sort { $b->{_damage}<=>$a->{_damage}
				   || $b->{ep}<=>$a->{ep}
				   || $b->{initiative}<=>$a->{initiative}
			       } grep {$_->{_damage}} @defenders;
	    if ($target) {
		$target->{_marked}++;
		$attacker->{_target} = $target;
	    }
	}
	printf "\n" if $part == 1;

	# attack
	my $total_kills = 0;
	for my $ag (sort {$b->{initiative}<=>$a->{initiative}} @groups) {
	    next unless $ag->{units}>0;
	    my $dg = $ag->{_target};
	    next unless $dg;

	    # make sure to update!
	    $ag->{ep} = $ag->{units}*$ag->{ad};
	    my $damage = $ag->{ep} * $dg->{_dmul};

	    local $ag->{_target} = undef;
	    local $dg->{_target} = undef;

	    # print Dumper $ag, $dg;

	    my $kills = 0;
	    while ($dg->{units}>0 && $damage >= $dg->{hp}) {
		$kills++;
		$dg->{units}--;
		$damage -= $dg->{hp};
	    }
	    $total_kills += $kills;

	    printf("%s group %d attacks defending group %d, killing %d units\n",
		   $ag->{army}, $ag->{group}, $dg->{group}, $kills,
		   ) if $part == 1;

	}
	printf "\n" if $part == 1;

	%alive = ();
	if ($total_kills) {
	    for my $g (values %groups) {
		next unless $g->{units}>0;
		$alive{$g->{army}}++;
	    }
	}
	last unless 2 == keys %alive;
    }

    if ($part == 2) {
	if ($alive{$boost_army}) {
	    last;
	}
	$boost++;
	# if ($boost == $boost_high) {
	#     $boost_low = $boost_high+1;
	#     $boost_high *= 2;
	#     $boost = $boost_high;
	# }
	# else {
	#     $boost_low = $boost;

	# }

    }
    else {
	last;
    }
}

printf "End of battle, boost = %d\n", $boost;

my $units = 0;
my @groups = grep { $_->{units}>0 } values %groups;
for my $g (sort {$a->{army} cmp $b->{army} || $a->{group}<=>$b->{group}}
	   @groups) {
    printf("%s %d contains %d units\n",
	   $g->{army}, $g->{group}, $g->{units},
	  );
    $units += $g->{units};
}

printf "Solution: winning army ends up with %d units\n", $units;
