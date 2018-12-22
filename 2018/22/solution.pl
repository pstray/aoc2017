#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2018 by Peder Stray <peder@wintermute>
#

use strict;

use Data::Dumper;
use Time::HiRes qw(usleep);
use Getopt::Long;

$| = 1;

my $debug;

GetOptions('d|debug!' => \$debug,
	  );

my $depth;
my($tx,$ty);

while (<>) {
    chomp;
    if (/^depth:\s*(\d+)/) {
	$depth = $1;
    }
    elsif (/^target:\s*(\d+)\s*,\s*(\d+)/) {
	$tx = $1;
	$ty = $2;
    }
    else {
	warn "Unparsable input:$.:$_\n";
    }
}

my $map = {};
my $state = {};
$state->{0}{0} = 'M';
$state->{$ty}{$tx} = 'T';
my $max_x = -1;
my $max_y = -1;

my $ans1 = gen_map($map,$tx,$ty);

draw_map($map,$max_x,$max_y,$state);

printf "Solutin 1: Risk level from 0,0 to %d,%d = %d\n", $tx,$ty, $ans1;

my $dmap = gen_dmap($map,0,0,$tx,$ty);

#draw_map($map,$max_x,$max_y,$dmap);

printf "Solution 2: Time to find target = %s\n", $dmap->{$ty}{$tx}[0];


exit;

# type\tool | climp 0 | torch 1 | neither 2 |
# rocky   0 |    X    |    X    |     -     |
# wet     1 |    X    |    -    |     X     |
# narrow  2 |    -    |    X    |     X     |
# not allowed tool = 2 - type;

sub gen_dmap_recurse {
    my($map,$xx,$yy,$tx,$ty,$dmap) = @_;

    # outside of map
    return if $xx < 0 || $yy < 0;

    # may need to expand map?
    return if $xx > $max_x || $yy > $max_y;
    #gen_map($map,$max_x + 5,$max_y) if $x > $max_x;
    #gen_map($map,$max_x,$max_y + 5) if $y > $max_y;

    my $cd = $dmap->{$yy}{$xx};
    my($time,$tools) = @$cd;

    if ($debug) {
	printf "\e[%d;%dH\e[48;5;240m%3d\e[m%1s", $yy+2, $xx*4+5, $time,
	  ('.','=','|')[$map->{$yy}{$xx}{type}];
	printf "\e[%d;%dH\e[J\n", $max_y+3, 1;
	usleep 100;
    }

    unless ($xx == $tx && $yy == $ty) {

	my @r;
	for my $p (
		   [$xx-1,$yy],
		   [$xx,$yy-1],
		   [$xx+1,$yy],
		   [$xx,$yy+1],
		  ) {
	    my($nx,$ny) = @$p;
	    next if $nx < 0 || $ny < 0;
	    return if $xx > $max_x || $yy > $max_y;

	    my $omt = $map->{$yy}{$xx}{type};
	    my $nmt = $map->{$ny}{$nx}{type};

	    my $recurse = 0;
	    my $nd = $dmap->{$ny}{$nx};

	    # printf "%d,%d => %d,%d (%s)\n",
	    #   $xx, $yy, $nx, $ny,
	    #   join(" ", sort keys %$tools)
	    #   ;

	    for my $ctool (keys %$tools) {
		for my $ntool (grep { 2-$nmt != $_ } 0..2) {
		    my $ntime = $time + 1;
		    $ntime += 7 unless $ctool == $ntool;

		    # printf " %d(%d)>%d(%d) N=%2d O=%2s ?\n",
		    #   $ctool, $omt,
		    #   $ntool, $nmt,
		    #   $ntime, $dmap->{$ny}{$nx}[0] // 'X',
		    #   ;

		    if ($nx == $tx && $ny == $ty) {
			# need to change tool to torch at end...
			$ntime += 7 unless $ntool == 1;
		    }

		    if (defined $dmap->{$ny}{$nx}[0]) {
			if ($dmap->{$ny}{$nx}[0] < $ntime) {
			    #printf "  skipping\n";
			}
			elsif ($dmap->{$ny}{$nx}[0] == $ntime) {
			    # print  "  update tool($ntool)\n";
			    $recurse++ unless $dmap->{$ny}{$nx}[1]{$ntool}++;
			}
			else {
			    $recurse++;
			    # printf "  set time($ntime) & tool($ntool)\n";
			    $dmap->{$ny}{$nx} = [ $ntime, { $ntool => 1 } ];
			}
		    }
		    else {
			$recurse++;
			# printf "  set time($ntime) & tool($ntool)\n";
			$dmap->{$ny}{$nx} = [ $ntime, { $ntool => 1 } ];
		    }
		}
	    }
	    push @r, [ $nx, $ny ] if $recurse;
	    # printf "\n";
	}

	# exit if $yy == 5;

	for my $r (@r) {
	    my($nx,$ny) = @$r;
	    gen_dmap_recurse($map,$nx,$ny,$tx,$ty,$dmap);
	}
    }


    if ($debug) {
	printf "\e[%d;%dH\e[m%3d\e[m", $yy+2, $xx*4+5, $time;
    }

}

sub gen_dmap {
    my($map,$sx,$sy,$tx,$ty) = @_;
    my $tool = 1; # (climb,torch,neither)

    my $dmap = {};
    my $time = 0;

    $dmap->{$sy}{$sx} = [ $time, { $tool => 1 } ];

    if ($debug) {
	#    printf "\e[?1049h\e[?25l";
	printf "\e[H\e[2J";
	printf "MAP ";
	for (0..$max_x) {
	    printf "%3d ", $_;
	}
	for (0..$max_y) {
	    printf "\n%3d", $_
	}
    }
    else {
	printf "Finding time to target...\n";
    }
    gen_dmap_recurse($map,$sx,$sy,$tx,$ty,$dmap);

    my $t2t = $dmap->{$ty}{$tx}[0];
    my $last_t2t = $t2t+1;
    printf "\e[%d;1H\e[J\n", $max_y+3;
    printf "T2T = %d\n", $t2t;
    my $expanded = 0;
    my $expand = 0;
    while ($t2t <= $last_t2t && $expanded++<25) {
	sleep 5 if $debug;
	# printf "Expanding map...\n";
	$expand++;
	my($mx,$my) = ($max_x,$max_y);
	gen_map($map,$mx+1,$my+1);
	if ($debug) {
	    #    printf "\e[?1049h\e[?25l";
	    printf "\e[H";
	    printf "MAP ";
	    for (0..$max_x) {
		printf "%3d ", $_;
	    }
	    for (0..$max_y) {
		printf "\n%3d", $_
	    }
	    printf "\e[J";
	}
	for my $y (0 .. $my) {
	    gen_dmap_recurse($map,$mx,$y,$tx,$ty,$dmap);
	}
	for my $x (0 .. $mx) {
	    gen_dmap_recurse($map,$x,$my,$tx,$ty,$dmap);
	}
	$last_t2t = $t2t;
	$t2t = $dmap->{$ty}{$tx}[0];
	$expanded = 0 if $t2t<$last_t2t;
	printf "\e[%d;1H\e[J\n", $max_y+3 if $debug;
	printf "T2T = %d after expando %d\n", $t2t, $expanded;
    }

    if ($debug) {
	# printf "\e[?12l\e[?25h\e[?1049l";
	printf "\e[%d;1H\n", $max_y+20;
    }

    return $dmap;
}

sub gen_map {
    my($map,$xx,$yy) = @_;
    my $risk = 0;

    for my $y (0 .. $max_y) {
	for my $x ($max_x+1 .. $xx) {
	    my($g_idx,$e_lvl,$type);
	    if ($x == 0 && $y == 0) {
		$g_idx = 0;
	    }
	    elsif ($x == $tx && $y == $ty) {
		$g_idx = 0;
	    }
	    elsif ($y == 0) {
		$g_idx = $x * 16807;
	    }
	    elsif ($x == 0) {
		$g_idx = $y * 48271;
	    }
	    else {
		$g_idx = $map->{$y}{$x-1}{e_lvl} * $map->{$y-1}{$x}{e_lvl};
	    }
	    $map->{$y}{$x}{e_lvl} = $e_lvl = ($g_idx + $depth) % 20183;
	    $map->{$y}{$x}{type}  = $type = $e_lvl % 3;
	    $risk += $type;
	}
    }

    for my $y ($max_y+1 .. $yy) {
	for my $x (0 .. $max_x) {
	    my($g_idx,$e_lvl,$type);
	    if ($x == 0 && $y == 0) {
		$g_idx = 0;
	    }
	    elsif ($x == $tx && $y == $ty) {
		$g_idx = 0;
	    }
	    elsif ($y == 0) {
		$g_idx = $x * 16807;
	    }
	    elsif ($x == 0) {
		$g_idx = $y * 48271;
	    }
	    else {
		$g_idx = $map->{$y}{$x-1}{e_lvl} * $map->{$y-1}{$x}{e_lvl};
	    }
	    $map->{$y}{$x}{e_lvl} = $e_lvl = ($g_idx + $depth) % 20183;
	    $map->{$y}{$x}{type}  = $type = $e_lvl % 3;
	    $risk += $type;
	}
    }

    for my $y ($max_y+1 .. $yy) {
	for my $x ($max_x+1 .. $xx) {
	    my($g_idx,$e_lvl,$type);
	    if ($x == 0 && $y == 0) {
		$g_idx = 0;
	    }
	    elsif ($x == $tx && $y == $ty) {
		$g_idx = 0;
	    }
	    elsif ($y == 0) {
		$g_idx = $x * 16807;
	    }
	    elsif ($x == 0) {
		$g_idx = $y * 48271;
	    }
	    else {
		$g_idx = $map->{$y}{$x-1}{e_lvl} * $map->{$y-1}{$x}{e_lvl};
	    }
	    $map->{$y}{$x}{e_lvl} = $e_lvl = ($g_idx + $depth) % 20183;
	    $map->{$y}{$x}{type}  = $type = $e_lvl % 3;
	    $risk += $type;
	}
    }

    $max_x = $xx;
    $max_y = $yy;

    return $risk;
}

sub draw_map {
    my($map,$xx,$yy,$state) = @_;
    for my $y (0 .. $yy) {
	for my $x (0 .. $xx) {
	    my($c,$fg,$bg);
	    if (exists $state->{$y}{$x}) {
		$c = $state->{$y}{$x};
		if (ref $c) {
		    $c = $c->[0];
		}
		if ($c =~ /^\d+$/) {
		    $c = (0..9,'a'..'z','A'..'Z')[$c] // '*';
		}
	    }
	    else {
		my $t = $map->{$y}{$x}{type};
		$c = (qw(. = |))[$t];
		$fg = (7, 12, 9)[$t];
	    }
	    $c = "\e[38;5;${fg}m$c" if $fg;
	    $c = "\e[48;5;${fg}m$c" if $bg;
	    $c .= "\e[m" if $fg || $bg;
	    printf "%1s", $c;
	}
	printf "\n";
    }
}
