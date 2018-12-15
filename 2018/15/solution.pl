#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

my %map;
my %units;

my($line);
my($max_x,$max_y);

$line=-1;
while (<>) {
    $line++;
    chomp;
    my $x = -1;
    my $y = $line;
    for my $c (split //) {
	$x++;
	if ($c eq '#') {
	    $map{$y}{$x} = $c;
	}
	elsif ($c eq '.') {
	    # $map{$y}{$x} = $c;
	}
	elsif ($c eq 'E' or $c eq 'G') {
	    $map{$y}{$x} = $units{$y}{$x} =
	      { type => $c, hp => 200, x => $x, y => $y, ap => 3 };
	}
	elsif ($c eq ' ') {
	    # in case of odd shaped map or 
	}
	else {
	    warn "found $c at $x,$y...\n";
	}
    }
    $max_x = $x if $x > $max_x;
}
$max_y = $line;

my $round = 0;

print_map("state at start",0,0,$max_x,$max_y,\%map);

round:
while (1) {
    printf "Round %d\n", $round+1;
    
    my @units;
    my %types;
    # find units in play
    for my $y (sort {$a<=>$b} keys %units) {
	for my $x (sort {$a<=>$b} keys %{$units{$y}}) {
	    my $u = $units{$y}{$x};
	    next unless $u;
	    die "wtf hp=0 in round setup" unless $u->{hp} > 0;
	    push @units, $u;
	    $types{$u->{type}}++;
	}
    }
    
    # let the units do their thing
    for my $me (@units) {
	# skip if dead;
	next unless $me->{hp} > 0;

	my $targets = grep { $types{$_}>0 } grep { $_ ne $me->{type} } keys %types;

	unless ($targets) {
	    printf " :: no more enemies left\n";
	    last round;
	}

	my $mx = $me->{x};
	my $my = $me->{y};

	printf " Unit at %d,%d\n", $mx, $my;

	# in range?
	my @in_range = in_range($me,\%units);
	
	if (!@in_range) {
	    # lets move;
	    # printf " :: move?...\n";
	    
	    # find enemies
	    my @enemies;
	    my $state;
	    for my $u (@units) {
		delete $u->{range};
		next unless $u->{target} = $u->{type} ne $me->{type};
		my $ux = $u->{x};
		my $uy = $u->{y};
		$state->{$uy-1}{$ux  } = '?' unless $map{$uy-1}{$ux};
		$state->{$uy  }{$ux-1} = '?' unless $map{$uy  }{$ux-1};
		$state->{$uy  }{$ux+1} = '?' unless $map{$uy  }{$ux+1};
		$state->{$uy+1}{$ux  } = '?' unless $map{$uy+1}{$ux};
	    }

	    # print_map("inrange", 0,0,$max_x,$max_y,\%map,$state);
	    
	    my $reach = find_reach($me,$state,\%map);

	    # print_map("possible", 0,0,$max_x,$max_y,\%map,$state);

	    my(@targets);
	    my $targets = 0;
	    for my $y (sort {$a<=>$b} keys %$state) {
		for my $x (sort {$a<=>$b} keys %{$state->{$y}}) {
		    $targets++;
		    next unless $state->{$y}{$x} eq '@';
		    push @targets, [ $reach->{$y}{$x}, $x, $y ];
		}
	    }

	    # anything reachable?

	    if (@targets) {
		printf " :: move...\n";

		#print_map("reachable", 0,0,$max_x,$max_y,\%map,$state);
		my($dist) = sort {$a<=>$b} map { $_->[0] } @targets;
		my($target) =
		  sort { $a->[2] <=> $b->[2] || $a->[1] <=> $b->[1] }
		  grep { $_->[0] == $dist } @targets;

		my $tx = $target->[1];
		my $ty = $target->[2];

		$state->{$ty}{$tx} = '+';

		print_map("select", 0,0,$max_x,$max_y,\%map,$state);
	       
		my $path = find_path($tx,$ty,$reach);

		my $path_d = $path->{$my}{$mx} - 1;
		
		my(@steps);
		for my $y (sort {$a<=>$b} keys %$path) {
		    for my $x (sort {$a<=>$b} keys %{$path->{$y}}) {
			next unless $path->{$y}{$x} == $path_d;
			push @steps, [ $x, $y ];
		    }
		}
		my($step) =
		  sort { $a->[1] <=> $b->[1] || $a->[0] <=> $b->[0] }
		  @steps;

		die "wtf step" unless $step;

		my($nx,$ny) = @$step;

		die "wtf newpos" if $map{$ny}{$nx};

		$units{$ny}{$nx} = delete $units{$my}{$mx};
		$map{$ny}{$nx} = delete $map{$my}{$mx};

		$me->{x} = $nx;
		$me->{y} = $ny;

		@in_range = in_range($me,\%units);

		#print_map("after move",0,0,$max_x,$max_y,\%map);

	    }
	}

	if (@in_range) {
	    print " :: fight...\n";

	    my($target) =
	      sort { $a->{hp} <=> $b->{hp} ||
		     $a->{y} <=> $b->{y} ||
		     $a->{x} <=> $b->{x} } @in_range;

	    $target->{hp} -= $me->{ap};
	    unless ($target->{hp} > 0) {
		my $tx = $target->{x};
		my $ty = $target->{y};
		printf " :: %s dies at %d,%d\n", $target->{type}, $tx, $ty;
		delete $map{$ty}{$tx};
		delete $units{$ty}{$tx};
		$types{$target->{type}}--;
	    }

	    # print Dumper $target;
	}

	printf "\n";
	
    }


    $round++;
    print_map("state after $round",0,0,$max_x,$max_y,\%map);

}

printf "\n";
printf "Battle ended in round %d\n\n", $round;

print_map("state after $round",0,0,$max_x,$max_y,\%map);

my $hp_sum = 0;
for my $y (sort {$a<=>$b} keys %units) {
    for my $x (sort {$a<=>$b} keys %{$units{$y}}) {
	my $u = $units{$y}{$x};
	next unless $u;
	die "wtf hp=0 in endgame calculations" unless $u->{hp} > 0;
	$hp_sum += $u->{hp};
    }
}

printf "Solution 1: after round %d, %d hp remains = %d\n",
  $round, $hp_sum, $round * $hp_sum;




exit 0;

sub find_path {
    my($sx,$sy,$reach) = @_;
    my $dist;
    my $d = $dist->{$sy}{$sx} = 1;
    my $r = $reach->{$sy}{$sx};
    $d++;
    find_path_recurse($sx  ,$sy-1,$r,$d,$dist,$reach);
    find_path_recurse($sx-1,$sy  ,$r,$d,$dist,$reach);
    find_path_recurse($sx+1,$sy  ,$r,$d,$dist,$reach);
    find_path_recurse($sx  ,$sy+1,$r,$d,$dist,$reach);

    print_map("path",0,0,$max_x,$max_y,$dist);

    return $dist;
}

sub find_path_recurse {
    my($sx,$sy,$r,$d,$dist,$reach) = @_;
    return if $dist->{$sy}{$sx};
    my $rr = $reach->{$sy}{$sx};
    return unless $rr;
    return if $rr > $r; # no need to follow longer paths
    $dist->{$sy}{$sx} = $d;
    $d++;
    find_path_recurse($sx  ,$sy-1,$rr,$d,$dist,$reach);
    find_path_recurse($sx-1,$sy  ,$rr,$d,$dist,$reach);
    find_path_recurse($sx+1,$sy  ,$rr,$d,$dist,$reach);
    find_path_recurse($sx  ,$sy+1,$rr,$d,$dist,$reach);
}

sub print_map {
    my($label,$x1,$y1,$x2,$y2,$map,$overlay) = @_;
    printf "%s:\n", $label;
    for my $y ($y1 .. $y2) {
	my(@u);
	for my $x ($x1 .. $x2) {
	    my $c = $overlay->{$y}{$x};
	    unless ($c) {
		$c = $map->{$y}{$x};
		if (ref $c) {
		    push @u, $c;
		    $c = $c->{type};
		}
	    }	    
	    if ($c =~ /^\d+$/) {
		$c = (0..9,'a'..'z')[$c]
	    }
	    printf("%1s", $c || '.');
	}
	if (@u) {
	    printf "   %s",
	      join ", ", map { $_->{type} . "(". $_->{hp} . ")" } @u;
	}
	printf "\n";
    }
    print "\n";
}
  
sub find_reach {
    my($me,$state,$map) = @_;
    my $x = $me->{x};
    my $y = $me->{y};
    my $reach;
    my $level = 1;
    $reach->{$y}{$x} = $level++;
    # here we could cut if already seen an enemy closer than level...
    find_reach_recurse($x  ,$y-1,$level,$reach,$state,$map);
    find_reach_recurse($x-1,$y  ,$level,$reach,$state,$map);
    find_reach_recurse($x+1,$y  ,$level,$reach,$state,$map);
    find_reach_recurse($x  ,$y+1,$level,$reach,$state,$map);

    # print_map("reach",0,0,$max_x,$max_y,$reach);

    return $reach;
}

sub find_reach_recurse {
    my($x,$y,$level,$reach,$state,$map) = @_;
    return if $map->{$y}{$x};
    my $r = $reach->{$y}{$x};
    return if defined $r && $r <= $level;
    if ($r) {
	$reach->{$y}{$x} = $level if $r > $level;
    }
    else {
	$reach->{$y}{$x} = $level;
    }
    $level++;
    if ($state->{$y}{$x}) {
	$state->{$y}{$x} = '@';
	#return;
    }
    find_reach_recurse($x,  $y-1,$level,$reach,$state,$map);
    find_reach_recurse($x-1,$y,  $level,$reach,$state,$map);
    find_reach_recurse($x+1,$y,  $level,$reach,$state,$map);
    find_reach_recurse($x,  $y+1,$level,$reach,$state,$map);
}

sub in_range {
    my($me,$units) = @_;
    my $x = $me->{x};
    my $y = $me->{y};
    my @r;
    
    push @r, $units->{$y-1}{$x} if exists $units->{$y-1}{$x};
    push @r, $units->{$y}{$x-1} if exists $units->{$y}{$x-1};
    push @r, $units->{$y}{$x+1} if exists $units->{$y}{$x+1};
    push @r, $units->{$y+1}{$x} if exists $units->{$y+1}{$x};

    return
      grep { $_->{hp} > 0 && $_->{type} ne $me->{type} } @r;
}
