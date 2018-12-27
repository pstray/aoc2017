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

$| = 1;

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

for my $bot (@bots) {
    my $dist =
      abs($bot->{x} - $strong->{x})+
      abs($bot->{y} - $strong->{y})+
      abs($bot->{z} - $strong->{z});
    if ($dist <= $max_r) {
	$in_range++;
    }
}

printf "Solution 1: Bots in range of strongest = %d\n", $in_range;


my($ans2,$n_bots) = solution2(\@bots);

printf "Solution 2: Distance to closes best point (%d bots) = %d\n",
  $n_bots, $ans2;

exit;

sub solution2 {
    my($bots) = @_;

    my $min_x = $bots[0]{x};
    my $min_y = $bots[0]{y};
    my $min_z = $bots[0]{z};
    my $max_x = $bots[0]{x};
    my $max_y = $bots[0]{y};
    my $max_z = $bots[0]{z};

    for my $bot (@$bots) {
	$min_z = $bot->{z} if $min_z > $bot->{z};
	$max_z = $bot->{z} if $max_z < $bot->{z};
	$min_y = $bot->{y} if $min_y > $bot->{y};
	$max_y = $bot->{y} if $max_y < $bot->{y};
	$min_x = $bot->{x} if $min_x > $bot->{x};
	$max_x = $bot->{x} if $max_x < $bot->{x};
    }

    printf "min_z %10d\n", $min_z;
    printf "max_z %10d\n", $max_z;
    printf "min_y %10d\n", $min_y;
    printf "max_y %10d\n", $max_y;
    printf "min_x %10d\n", $min_x;
    printf "max_x %10d\n", $max_x;

    my $dist = 1;
    while ($dist < $max_x - $min_x ||
	   $dist < $max_y - $min_y ||
	   $dist < $max_z - $min_z) {
	$dist *= 2;
    }

    printf "dist %10d\n", $dist;

    my $span = 1;
    while ($span < @bots) {
	$span *= 2;
    }
    printf "Span = %d\n", $span;

    my $target_n = 1; # ???
    my %tries;

    my($max_n, $min_d);

    while (1) {
	printf "Testing for %d (%d,%d)...\n", $target_n, $dist, $span;

	$tries{$target_n} ||= [ find_solution({}, $bots,
					      $min_x, $max_x,
					      $min_y, $max_y,
					      $min_z, $max_z,
					      $dist, $target_n,
					     ) ];
	my($test_d, $test_n) = @{$tries{$target_n}};

	if (! defined $test_d) {
	    $span = int($span/2) if $span > 1;
	    ($target_n) = sort {$b<=>$a} 1, $target_n-$span;
	}
	else {
	    if ($test_n > $max_n) {
		$max_n = $test_n;
		$min_d = $test_d;
	    }
	    if ($span == 1) {
		last;
	    }
	    $target_n += $span;
	}
    }

    return wantarray ? ($min_d, $max_n) : $min_d;
}

sub find_solution {
    my($done, $bots,
       $min_x, $max_x, $min_y, $max_y, $min_z, $max_z,
       $dist, $target_n) = @_;

    # printf "  Finding at %d,%d,%d (%d)\r", $min_x, $min_y, $min_z, $dist;

    my @at_target;

    for (my $z = $min_z; $z <= $max_z; $z += $dist) {
	for (my $y = $min_y; $y <= $max_y; $y += $dist) {
	    for (my $x = $min_x; $x <= $max_x; $x += $dist) {

		my $n = 0;
		for my $b (@$bots) {
		    my($bx,$by,$bz,$br) = @{$b}{qw(x y z r)};
		    my $d = abs($x-$bx)+abs($y-$by)+abs($z-$bz);

		    if ($dist == 1) {
			$n++ if $d <= $br;
		    }
		    else {
			$n++ if int($d/$dist)-3 <= int($br/$dist);
		    }
		}

		if ($n >= $target_n) {
		    push @at_target, { x => $x,
				       y => $y,
				       z => $x,
				       n => $n,
				       d => abs($x)+abs($y)+abs($z),
				     };
		}
	    }
	}
    }

    while (@at_target) {
	my $best_i = 0;
	my $best = $at_target[$best_i];
	for my $i (1 .. @at_target-1) {
	    my $t = $at_target[$i];
	    if ($t->{d} < $best->{d}) {
		$best = $t;
		$best_i = $i;
	    }
	}

	if ($dist == 1) {
	    return ($best->{d}, $best->{n});
	}
	else {
	    my $ndist = int($dist/2);
	    my($x1,$x2) = ($best->{x}, $best->{x} + $ndist);
	    my($y1,$y2) = ($best->{y}, $best->{y} + $ndist);
	    my($z1,$z2) = ($best->{z}, $best->{z} + $ndist);
	    my($d,$n) = find_solution($done, $bots,
				      $x1, $x2, $y1, $y2, $z1, $z2,
				      $ndist, $target_n,
				     );
	    if (!$d) {
		splice @at_target, $best_i, 1;
	    }
	    else {
		return ($d, $n);
	    }
	}
    }
    return;
}

__END__

exit;

sub recurse_voxel {
    my($qx1, $qx2, $qy1, $qy2, $qz1, $qz2, $odiv, $bots, $bot_ids,
       $whole, $max_n, $min_d) = @_;
    my(%whole);
    my $nx = ($qx2-$qx1)/$odiv+1;
    my $ny = ($qy2-$qy1)/$odiv+1;
    my $nz = ($qz2-$qz1)/$odiv+1;
    my $max_hits = $nx*$ny*$nz;

    printf "\r* Recursing down into %10d,%10d,%10d (%d+%d=%d, %d)\e[K\n", $qx1, $qy1, $qz1, $whole, 0+@$bot_ids, $whole+@$bot_ids, $odiv;

    my %subspace;
    for my $bi (sort {$a<=>$b} @$bot_ids) {
	# printf "\r  ... Scanning %4d\e[K", $bi;
	my $bot = $bots->[$bi];

	my($bx, $by, $bz, $br) = @{$bot}{qw(x y z r)};

	my($min_x) = sort {$b<=>$a} $qx1, floor(($bx-$br)/$odiv)*$odiv;
	my($max_x) = sort {$a<=>$b} $qx2,  ceil(($bx+$br)/$odiv)*$odiv;
	my($min_y) = sort {$b<=>$a} $qy1, floor(($by-$br)/$odiv)*$odiv;
	my($max_y) = sort {$a<=>$b} $qy2,  ceil(($by+$br)/$odiv)*$odiv;
	my($min_z) = sort {$b<=>$a} $qz1, floor(($bz-$br)/$odiv)*$odiv;
	my($max_z) = sort {$a<=>$b} $qz2,  ceil(($bz+$br)/$odiv)*$odiv;

	# printf "\r %4d %10d, %10d, %10d\e[K", $bi, $min_x, $min_y, $min_z;

	my $hits = 0;
	my %s;
	for (my $vz = $min_z; $vz <= $max_z; $vz += $odiv) {
	    my $dz = abs($vz-$bz);
	    my $zi = ($vz-$qz1)/$odiv;
	    for (my $vy = $min_y; $vy <= $max_y; $vy += $odiv) {
		my $dy = abs($vy-$by);
		next unless $dz+$dy <= $br || ($vy <= $by && $by < $vy+$odiv);
		my $yi = ($vy-$qy1)/$odiv;
		for (my $vx = $min_x; $vx <= $max_x; $vx += $odiv) {
		    my $dx = abs($vx-$by);
		    next unless $dz+$dy+$dx <= $br || ($vx <= $bx && $bx < $vx+$odiv);
		    my $xi = ($vx-$qx1)/$odiv;
		    $hits++;
		    my $pos = ($zi*$ny+$yi)*$nx+$xi;
		    # printf "%6d %10d %10d %10d\n", $pos, $xi, $yi, $zi;
		    $s{$pos}{$bi}++;
		}
	    }
	}

	if ($hits == $max_hits) {
	    $whole{$bi}++;
	}
	else {
	    for my $p (keys %s) {
		for my $b (keys %{$s{$p}}) {
		    $subspace{$p}{$b}++;
		}
	    }
	}

    } # bots


    if (keys %subspace) {

	my %counts = map { $_ => 0+keys %{$subspace{$_}} } keys %subspace;

	# loop through subspaces with most bots first
	for my $p (sort { $counts{$b} <=> $counts{$a} } keys %subspace) {
	    my $v = $subspace{$p};
	    my @ids = sort { $a<=>$b } keys %$v;

	    my $x = $qx1 + $odiv*($p % $nx);
	    my $y = $qy1 + $odiv*(int($p/$nx) % $ny);
	    my $z = $qz1 + $odiv*(int($p/$nx/$ny) % $nz);

	    my $s_whole;

	    if ($x == $qx2 || $y == $qx2 || $z == $qz2) {
		@ids = sort @ids, keys(%whole);
		$s_whole = $whole;
	    }
	    else {
		$s_whole = $whole + keys(%whole);
	    }

	    next if @ids+$s_whole < $max_n; # no possibilty

	    if (@ids+$s_whole == $max_n) {
		my $min_vx = abs( (abs($x) > abs($x+$odiv)) ? $x+$odiv-1 : $x );
		my $min_vy = abs( (abs($y) > abs($y+$odiv)) ? $y+$odiv-1 : $y );
		my $min_vz = abs( (abs($z) > abs($z+$odiv)) ? $z+$odiv-1 : $z );

		printf "XX negative space\n" if $min_vx != $x ||
		  $min_vy != $y ||
		  $min_vz != $z;

		my $min_vd = $min_vx + $min_vy + $min_vz;

		next if $min_vd > $min_d;
	    }

	    my($d,$n);

	    if ($odiv>1) {
		my $ndiv = int($odiv/10);
		($n,$d) = recurse_voxel($x, $x+9*$ndiv,
					$y, $y+9*$ndiv,
					$z, $z+9*$ndiv,
					$ndiv,
					$bots, [ @ids ],
					$s_whole, $max_n, $min_d,
				       );
	    }
	    else {
		$d = abs($x)+abs($y)+abs($z);
		$n = $s_whole+@ids;
	    }

	    if ($n > $max_n) {
		$max_n = $n;
		$min_d = $d;
		($gx, $gy, $gz) = ($x, $y, $z);
	    }
	    elsif ($n == $max_n) {
		if ($d < $min_d) {
		    $min_d = $d;
		    ($gx, $gy, $gz) = ($x, $y, $z);
		}
	    }
	}
    }
    else {
	if ($whole) {

	    my $min_dx = abs( (abs($qx1) > abs($qx2)) ? $qx2+$odiv-1 : $qx1 );
	    my $min_dy = abs( (abs($qy1) > abs($qy2)) ? $qy2+$odiv-1 : $qy1 );
	    my $min_dz = abs( (abs($qz1) > abs($qz2)) ? $qz2+$odiv-1 : $qz1 );
	    my $min_dist = $min_dx+$min_dy+$min_dz;

	    if ($whole > $max_n) {
		$min_d = $min_dist;
	    }
	    elsif ($whole == $max_n) {
		$min_d = $min_dist if $min_dist < $min_d;
	    }
	}
	else {
	    # no points here;
	    $max_n = 0;
	    $min_d = 0;
	}
    }

    printf "\r  Return %4d, %10d \e[K\r\e[A  ", $max_n, $min_d;

    # printf "\r\e[K\e[A\e[K";
    # printf "\r  \e[A\r  ";

    return ($max_n, $min_d);
}
