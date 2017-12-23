#! /usr/bin/perl

use strict;

use Data::Dumper;
$Data::Dumper::Sortkeys = $Data::Dumper::Indent = 1;

@ARGV = qw(input) unless @ARGV;

my $grid;
while (<>) {
    chomp;
    push @$grid, $_;
}

sub dump_map {
    my($state, $iteration) = @_;
    my @extra = (
		 sprintf("x = %3d", $state->{pos_x}),
		 sprintf("y = %3d", $state->{pos_y}),
		 sprintf("d = %s", (qw(UP RIGHT DOWN LEFT))[$state->{dir}]),
		);
    printf "--[%3d ]--%s\n",$iteration,"-" x 60;
    for my $y ($state->{min_y}-3 .. $state->{max_y}+3) {
	my $l = " ";
	for my $x ($state->{min_x}-3 .. $state->{max_x}+3) {
	    $l .= sprintf "%s ", substr $state->{states}, $state->{$x,$y}, 1;
	}
	if ($state->{pos_y} == $y) {
	    substr($l,2*($state->{pos_x}-$state->{min_x}+3)  ,1) = '[';
	    substr($l,2*($state->{pos_x}-$state->{min_x}+3)+2,1) = ']';
	}
	printf "%s  %s\n", $l, shift @extra;
    }
}

sub do_infections {
    my($grid,$states,$iterations,$draw) = @_;
    my %changes;

    my %state;
    my $min_x = 0;
    my $max_x = 0;
    my $min_y = 0;
    my $max_y = 0;
    my $pos_x = 0;
    my $pos_y = 0;
    my $dir   = 0;

    my @states = split //, $states;
    my %state_map = ( map { $states[$_] => $_ } 0 .. @states-1);

    my $y_mid = int(@$grid/2);
    my $x_mid = int(length($grid->[$y_mid])/2);
    for my $y (0 .. @$grid-1) {
	my $iy = $y-$y_mid;
	for my $x (0 .. length($grid->[$y])-1) {
	    my $ix = $x-$x_mid;
	    $state{$ix}{$iy} = $state_map{substr($grid->[$y], $x, 1)};
	    $min_x = $ix if $ix < $min_x;
	    $max_x = $ix if $ix > $max_x;
	}
	$min_y = $iy if $iy < $min_y;
	$max_y = $iy if $iy > $max_y;
    }

    my @add;
    $add[$state_map{"#"}] = 1;
    $add[$state_map{"."}] = -1;
    $add[$state_map{"F"}] = 2 if exists $state_map{"F"};

    for (1 .. $iterations) {
	my $s = \$state{$pos_x}{$pos_y};

	$dir += $add[$$s];
	# if ($$s == $state_map{"#"}) {
	#     $dir += 1; # turn right
	# }
	# elsif ($$s == $state_map{"."}) {
	#     $dir -= 1; # turn left
	# }
	# elsif ($$s == $state_map{"F"}) {
	#     $dir += 2; # turn around
	# }
	$dir %= 4;

	$$s++;
	$$s %= @states;

	$changes{$states[$$s]}++;
	
	if ($dir == 0) { # up
	    $pos_y--;
	    #$min_y = $pos_y if $pos_y < $min_y;
	}
	elsif ($dir == 1) { # right
	    $pos_x++;
	    #$max_x = $pos_x if $pos_x > $max_x;
	}
	elsif ($dir == 2) { # down
	    $pos_y++;
	    #$max_y = $pos_y if $pos_y > $max_y;
	}
	elsif ($dir == 3) { # left;
	    $pos_x--;
	    #$min_x = $pos_x if $pos_x < $min_x;
	}
	else {
	    die "state{dir} is weird [$dir]\n";
	}
    }
    return \%changes;
}

my $changes;

#$changes = do_infections($grid,'.#',70,1);
$changes = do_infections($grid,'.#',10_000);

printf "Solution 1: %d infections\n", $changes->{"#"};

#$changes = do_infections($grid, '.W#F',100,1);
$changes = do_infections($grid, '.W#F',10_000_000);

#print Dumper $changes;

printf "Solution 2: %d infections\n", $changes->{"#"};
