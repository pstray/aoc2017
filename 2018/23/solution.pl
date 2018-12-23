#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;
use Data::Dumper;
$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;
use POSIX;

my @bots;
my $max_r = -1;
my $strong;

while (<>) {
    chomp;
    if (/^pos=<(?<x>-?\d+),(?<y>-?\d+),(?<z>-?\d+)>, r=(?<r>\d+)$/) {
	push @bots, {%+};
	if ($+{r} > $max_r) {
	    $max_r = $+{r};
	    $strong = $bots[-1];
	}
    }
    else {
	die "Unparsable input:$.: $_\n";
    }
}

my $in_range = 0;
my $max_v = 0;

for my $bot (@bots) {
    my $dist =
      abs($bot->{x} - $strong->{x})+
      abs($bot->{y} - $strong->{y})+
      abs($bot->{z} - $strong->{z});
    if ($dist <= $max_r) {
	$in_range++;
    }
    for (@{$bot}{qw(x y z r)}) {
	$max_v = abs($_) if abs($_) > $max_v;
    }
}

printf "Solution 1: Bots in range of stronges = %d\n", $in_range;

my $d_max = 1;
while ($d_max*100 < $max_v) {
    $d_max *= 10;
}

$| = 1;

# initial loop
my %space;
my $most = 0;
for my $bi (0 .. @bots-1) {
    my $bot = $bots[$bi];
    my $div = $d_max;
    printf "%5d %10d\r", $bi, $div;

    my($bx,$by,$bz,$br) = @{$bot}{qw(x y z r)};

    for (my $z = $bz-$br; $z <= $bz+$br; $z += $div) {
	my $dz = abs($z-$bz);
	my $iz = floor($z/$div)*$div;
	for (my $y = $by-$br; $y <= $by+$br; $y += $div) {
	    my $dy = abs($y-$by);
	    next if $dz+$dy > $br;
	    my $iy = floor($y/$div)*$div;
	    for (my $x = $bx-$br; $x <= $bx+$br; $x += $div) {
		my $dx = abs($x-$bx);
		next if $dz+$dy+$dx > $br;
		my $ix = floor($x/$div)*$div;
		$space{"$ix,$iy,$iz,$div"}{$bi}++;
	    }
	}
    }
}
printf "\n";

printf "Starting with %d voxels\n", 0+keys %space;

my $clean_size = 500;
my @finals;
while (1) {

    my %counts;
    my $deleted = 0;
    for my $id (keys %space) {
	my $c = keys %{$space{$id}};
	if ($c <= $clean_size) {
	    delete $space{$id};
	    $deleted++;
	}
	else {
	    $counts{$id} = $c;
	}
    }
    my @voxels = sort {$counts{$b}<=>$counts{$a}} keys %space;

    printf "Deleted %d with single bots, %d left\n", $deleted, 0+@voxels;

    my $most = $counts{$voxels[0]};
    my @queue;
    while ($counts{$voxels[0]} == $most) {
	push @queue, shift @voxels;
    }
    printf "Most = %d (%d qued, %d left)\n", $most, 0+@queue, 0+@voxels;

    my %new_voxels;
    @finals = ();

    for my $q (@queue) {
	my($qx,$qy,$qz,$div) = split ",", $q;
	my $s = delete $space{$q};

	if ($div == 1) {
	    push @finals, $q;
	    next;
	}

	printf "  Splitting (%9d,%9d,%9d)\n", $qx, $qy, $qz;

	my $max_x = $qx+$div;
	my $max_y = $qy+$div;
	my $max_z = $qz+$div;

	$div = int($div/10);

	my %visited;
	for my $bi (sort {$a<=>$b} keys %$s) {
	    my $bot = $bots[$bi];
	    # printf "%5d\r", $bi+1;

	    my($bx,$by,$bz,$br) = @{$bot}{qw(x y z r)};

	    my $min_z = $bz - int(($bz-$qz)/$div-1)*$div;
	    my $min_y = $by - int(($by-$qy)/$div-1)*$div;
	    my $min_x = $bx - int(($bx-$qx)/$div-1)*$div;

	    for (my $z = $min_z; $z < $max_z; $z += $div) {
		my $dz = abs($z-$bz);
		my $iz = floor($z/$div)*$div;
		for (my $y = $min_y; $y < $max_y; $y += $div) {
		    my $dy = abs($y-$by);
		    next if $dz+$dy > $br;
		    my $iy = floor($y/$div)*$div;
		    for (my $x = $min_x; $x < $max_x; $x += $div) {
			my $dx = abs($x-$bx);
			next if $dz+$dy+$dx > $br;
			my $ix = floor($x/$div)*$div;
			my $id = "$ix,$iy,$iz,$div";
			$space{$id}{$bi}++;
			$visited{$id}++;
		    }
		}
	    }
	}
	my $deleted = 0;
	for my $id (keys %visited) {
	    if (keys(%{$space{$id}}) <= $clean_size) {
		delete $space{$id};
		$deleted++;
	    }
	}
	printf "    Removed %d of %d\n", $deleted, 0+keys %visited;
    }
    if (@finals == @queue) {
	last;
    }
}

my @dists;
for my $id (@finals) {
    my($x,$y,$z,$div) = split "\x1c", $id;
    push @dists, $x+$y+$z;
}

my($ans2) = sort {$b<=>$a} @dists;

printf "Solution 2: Shortest distance to max range point = %d\n", $ans2;


__END__
my @points = grep { $space->{$_} == $most } keys %$space;

my %dists;

for my $p (@points) {
    my($x,$y,$z) = split "\x1c", $p;
    printf "   %d,%d,%d\n", $x, $y, $z;
}
