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
    
    my %state =
      (
       min_x => 0,
       max_x => 0,
       min_y => 0,
       max_y => 0,
       pos_x => 0,
       pos_y => 0,
       dir => 0,
       states => $states,
      );

    my @states = split //, $states;
    my %state_map = ( map { $states[$_] => $_ } 0 .. @states-1);

    my $y_mid = int(@$grid/2);
    my $x_mid = int(length($grid->[$y_mid])/2);
    for my $y (0 .. @$grid-1) {
	my $iy = $y-$y_mid;
	for my $x (0 .. length($grid->[$y])-1) {
	    my $ix = $x-$x_mid;
	    $state{$ix,$iy} = $state_map{substr($grid->[$y], $x, 1)};
	    $state{min_x} = $ix if $ix < $state{min_x};
	    $state{max_x} = $ix if $ix > $state{max_x};
	}
	$state{min_y} = $iy if $iy < $state{min_y};
	$state{max_y} = $iy if $iy > $state{max_y};
    }

    if ($draw) {
	dump_map(\%state,0);
	# sleep 1 if $iterations < 100;
    }

    for (1 .. $iterations) {
	if ($state{$state{pos_x},$state{pos_y}} == $state_map{"#"}) {
	    $state{dir} += 1; # turn right
	}
	elsif ($state{$state{pos_x},$state{pos_y}} == $state_map{"."}) {
	    $state{dir} -= 1; # turn left
	}
	elsif ($state{$state{pos_x},$state{pos_y}} == $state_map{"F"}) {
	    $state{dir} += 2; # turn around
	}
	$state{dir} %= 4;

	$state{$state{pos_x},$state{pos_y}}++;
	$state{$state{pos_x},$state{pos_y}} %= @states;

	$changes{$states[$state{$state{pos_x},$state{pos_y}}]}++;
	
	if ($state{dir} == 0) { # up
	    $state{pos_y}--;
	    $state{min_y} = $state{pos_y} if $state{pos_y} < $state{min_y};
	}
	elsif ($state{dir} == 1) { # right
	    $state{pos_x}++;
	    $state{max_x} = $state{pos_x} if $state{pos_x} > $state{max_x};
	}
	elsif ($state{dir} == 2) { # down
	    $state{pos_y}++;
	    $state{max_y} = $state{pos_y} if $state{pos_y} > $state{max_y};
	}
	elsif ($state{dir} == 3) { # left;
	    $state{pos_x}--;
	    $state{min_x} = $state{pos_x} if $state{pos_x} < $state{min_x};
	}
	else {
	    die "state{dir} is weird [$state{dir}]\n";
	}

	if ($draw) {
	    dump_map(\%state,$_);
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
