#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;

$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

my($line);
my($max_x,$max_y);

my %color_map =
  ( '#' => 3,
    '.' => 242,
    '@' => 6,
    '+' => 14,
  );

my @init_units;
my %init_map;

$line=-1;
while (<>) {
    $line++;
    chomp;
    my $x = -1;
    my $y = $line;
    for my $c (split //) {
	$x++;
	if ($c eq '#') {
 	    $init_map{$y}{$x} = $c;
	}
	elsif ($c eq '.') {
	    # $init_map{$y}{$x} = $c;
	}
	elsif ($c eq 'E') {
	    push @init_units,
	      { type => $c, hp => 200, x => $x, y => $y, ap => 3,
		name => 'Elf', color => 10,
	      };
	}
	elsif ($c eq 'G') {
	    push @init_units,
	      { type => $c, hp => 200, x => $x, y => $y, ap => 3,
		name => 'Goblin', color => 9,
	      };
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

my $ap = 2;

battle:
while (1) {
    $ap++;
    my %map;
    my %units;

    for my $y (keys %init_map) {
	for my $x (keys %{$init_map{$y}}) {
	    $map{$y}{$x} = $init_map{$y}{$x};
	}
    }

    for (@init_units) {
	my $unit = { %$_ };
	my $x = $unit->{x};
	my $y = $unit->{y};
	$map{$y}{$x} = $units{$y}{$x} = $unit;
	if ($unit->{type} eq 'E') {
	    $unit->{ap} = $ap;
	}
    }

    printf "Running battle with Elf attack power %d\n", $ap;
    
    my $round = 0;
  round:
    while (1) {
	printf "Round %d\n", $round+1
	  unless $ap>3;
	
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
	    
	    my $mx = $me->{x};
	    my $my = $me->{y};
	    
	    local $me->{bg} = 7;
	    
#	    printf " Unit at %d,%d\n", $mx, $my
#	      unless $ap>3;
	    
	    my $targets = grep { $types{$_}>0 } grep { $_ ne $me->{type} } keys %types;
	    
	    unless ($targets) {
		printf " :: no more enemies left\n";
		last round;
	    }
	    
	    # in range?
	    my @adjecent = find_adjecent($me,\%units);
	    
	    if (!@adjecent) {
		# lets move;
		
		# find enemies
		my @enemies;
		my $state;
		
		for my $u (@units) {
		    delete $u->{range};
		    next unless $u->{target} = $u->{type} ne $me->{type};
		    next unless $u->{hp} > 0;
		    my $ux = $u->{x};
		    my $uy = $u->{y};
		    $state->{$uy-1}{$ux  } = '?' unless $map{$uy-1}{$ux};
		    $state->{$uy  }{$ux-1} = '?' unless $map{$uy  }{$ux-1};
		    $state->{$uy  }{$ux+1} = '?' unless $map{$uy  }{$ux+1};
		    $state->{$uy+1}{$ux  } = '?' unless $map{$uy+1}{$ux};
		}
		
		# print_map("inrange", 0,0,$max_x,$max_y,\%map,$state);
		
		my $reach = find_reach($me,$state,\%map);
		
		# print_map("reach",0,0,$max_x,$max_y,\%map,$reach);
		
		my(@targets);
		for my $y (sort {$a<=>$b} keys %$state) {
		    for my $x (sort {$a<=>$b} keys %{$state->{$y}}) {
			next unless $state->{$y}{$x} eq '@';
			push @targets, [ $reach->{$y}{$x}, $x, $y ];
		    }
		}
		
		# anything reachable?
		if (@targets) {
		    #printf " :: move...\n"
		    #  unless $ap>3;
		    
		    # print_map("reachable", 0,0,$max_x,$max_y,\%map,$state);
		    my($dist) = sort {$a<=>$b} map { $_->[0] } @targets;
		    
		    # printf " :: closeest at %d steps\n", $dist;
		    
		    my($target) =
		      sort { $a->[2] <=> $b->[2] || $a->[1] <=> $b->[1] }
		      grep { $_->[0] == $dist } @targets;
		    
		    my $tx = $target->[1];
		    my $ty = $target->[2];
		    
		    $state->{$ty}{$tx} = '+';
		    
		    #print_map("select",0,0,$max_x,$max_y,\%map,$state)
		    #  unless $ap>3;
		    
		    my $path = find_path($tx,$ty,$reach);
		    
		    # print_map("path",0,0,$max_x,$max_y,$path);
		    
		    my $path_d = $path->{$my}{$mx} - 1;
		    
		    my(@steps);
		    my($steps);
		    for my $y (sort {$a<=>$b} keys %$path) {
			for my $x (sort {$a<=>$b} keys %{$path->{$y}}) {
			    next unless $path->{$y}{$x} == $path_d;
			    push @steps, [ $x, $y ];
			    $steps->{$y}{$x} = { map => '*', color => 5 };
			}
		    }
		    
		    my($step) =
		      sort { $a->[1] <=> $b->[1] || $a->[0] <=> $b->[0] }
		      @steps;
		    
		    die "wtf step" unless $step;
		    
		    my($nx,$ny) = @$step;
		    
		    $steps->{$ny}{$nx}{color} += 8;

		    unless ($ap>3) {
			print "\e[H\e[2J";
			print_map("move $round/$ap",0,0,$max_x,$max_y,\%map,$steps);
		    }
		    
		    die "wtf newpos" if $map{$ny}{$nx};
		    
		    $units{$ny}{$nx} = delete $units{$my}{$mx};
		    $map{$ny}{$nx} = delete $map{$my}{$mx};
		    
		    $me->{x} = $nx;
		    $me->{y} = $ny;
		    
		    @adjecent = find_adjecent($me,\%units);
		    
		    # print_map("after move",0,0,$max_x,$max_y,\%map);
		    
		}
	    }
	    
	    if (@adjecent) {
		#print " :: fight...\n"
		#  unless $ap>3;
		
		my($target) =
		  sort { $a->{hp} <=> $b->{hp} ||
			 $a->{y} <=> $b->{y} ||
			 $a->{x} <=> $b->{x} } @adjecent;
		
		$target->{hp} -= $me->{ap};
		unless ($target->{hp} > 0) {
		    my $tx = $target->{x};
		    my $ty = $target->{y};
		    printf " :: %s dies at %d,%d in round %d\n", $target->{name}, $tx, $ty, $round+1;
		    delete $map{$ty}{$tx};
		    delete $units{$ty}{$tx};
		    $types{$target->{type}}--;

		    if ($ap>3 && $target->{type} eq 'E') {
			next battle;
		    }
		}
		
		# print Dumper $target;
	    }
	}
	
	$round++;
	#unless ($ap>3) {
	    printf "\e[H\e[2J";
	    print_map("state after $round/$ap",0,0,$max_x,$max_y,\%map)
	#}
	
    }

    printf "\n";

    printf "\e[H\e[2J";
    print_map("End of battle",0,0,$max_x,$max_y,\%map);

    printf "Battle ended in round %d\n\n", $round;
    
    my $hp_sum = 0;
    for my $y (sort {$a<=>$b} keys %units) {
	for my $x (sort {$a<=>$b} keys %{$units{$y}}) {
	    my $u = $units{$y}{$x};
	    next unless $u;
	    die "wtf hp=0 in endgame calculations" unless $u->{hp} > 0;
	    $hp_sum += $u->{hp};
	}
    }

    printf "Solution %d: after round %d with ap %d, %d hp remains = %d\n\n",
      $ap>3 ? 2 : 1,
      $round, $ap, $hp_sum, $round * $hp_sum;

    last if $ap>3;
}

exit 0;

sub find_path {
    my($sx,$sy,$reach) = @_;
    my $dist;
    my $d = $dist->{$sy}{$sx} = 0;
    my $r = $reach->{$sy}{$sx};
    $d++;
    find_path_recurse($sx  ,$sy-1,$r,$d,$dist,$reach);
    find_path_recurse($sx-1,$sy  ,$r,$d,$dist,$reach);
    find_path_recurse($sx+1,$sy  ,$r,$d,$dist,$reach);
    find_path_recurse($sx  ,$sy+1,$r,$d,$dist,$reach);

    return $dist;
}

sub find_path_recurse {
    my($sx,$sy,$r,$d,$dist,$reach) = @_;
    return if $dist->{$sy}{$sx};
    my $rr = $reach->{$sy}{$sx};
    return unless defined $rr;
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
    printf "map: %s:\n", $label;
    for my $y ($y1 .. $y2) {
	my(@u);
	for my $x ($x1 .. $x2) {
	    my $color;
	    my $bg;
	    my $c = $overlay->{$y}{$x} || $map->{$y}{$x};
	    if (ref $c) {
		push @u, $c if $c->{type};
		$color = $c->{color};
		$bg = $c->{bg};
		$c = $c->{map} || $c->{type};
	    }
	    if ($c =~ /^\d+$/) {
		$bg = int(255-$c/2);
		$bg = 232 if $bg < 232;
		$c = (0..9,'a'..'z')[$c] // 'X';
	    }
	    $c //= '.';
	    $color //= $color_map{$c};
	    $c = "\e[38;5;${color}m$c" if defined $color;
	    $c = "\e[48;5;${bg}m$c" if defined $bg;
	    $c .= "\e[m" if $color || $bg;
  	    printf("%1s", $c);
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
    my $level = 0;#XXX#
    $reach->{$y}{$x} = $level++;
    # here we could cut if already seen an enemy closer than level...
    find_reach_recurse($x  ,$y-1,$level,$reach,$state,$map);
    find_reach_recurse($x-1,$y  ,$level,$reach,$state,$map);
    find_reach_recurse($x+1,$y  ,$level,$reach,$state,$map);
    find_reach_recurse($x  ,$y+1,$level,$reach,$state,$map);

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

sub find_adjecent {
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
