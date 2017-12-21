#! /usr/bin/perl

use strict;

use Data::Dumper;
$Data::Dumper::Sortkeys = $Data::Dumper::Indent = 1;

@ARGV = qw(input) unless @ARGV;

my @art = (".#.", "..#", "###");
my $size = 3;

my %rules;

while (<>) {
    chomp;
    if (my @rule = m,^(.)(.)/(.)(.) => (...)/(...)/(...)$,) {
	my $block = [ @rule[4..6] ];
	# 0 1
	# 2 3
	$rules{2}{sprintf "%s%s/%s%s", @rule[qw(0 1 2 3)]} = $block; # 0
	$rules{2}{sprintf "%s%s/%s%s", @rule[qw(1 0 3 2)]} = $block; # flip |
	$rules{2}{sprintf "%s%s/%s%s", @rule[qw(2 3 0 1)]} = $block; # flip -

	$rules{2}{sprintf "%s%s/%s%s", @rule[qw(1 3 0 2)]} = $block; # 90 ccw
#	$rules{2}{sprintf "%s%s/%s%s", @rule[qw(3 1 0 2)]} = $block; # flip |
#	$rules{2}{sprintf "%s%s/%s%s", @rule[qw(0 2 1 3)]} = $block; # flip -

	$rules{2}{sprintf "%s%s/%s%s", @rule[qw(3 2 1 0)]} = $block; # 180 
#	$rules{2}{sprintf "%s%s/%s%s", @rule[qw(2 3 0 1)]} = $block; # flip |
#	$rules{2}{sprintf "%s%s/%s%s", @rule[qw(1 0 3 2)]} = $block; # flip -

	$rules{2}{sprintf "%s%s/%s%s", @rule[qw(2 0 3 1)]} = $block; # 90 cw
#	$rules{2}{sprintf "%s%s/%s%s", @rule[qw(0 2 1 3)]} = $block; # flip |
#	$rules{2}{sprintf "%s%s/%s%s", @rule[qw(3 1 2 0)]} = $block; # flip -

    }
    elsif (my @rule = m,^(.)(.)(.)/(.)(.)(.)/(.)(.)(.) => (....)/(....)/(....)/(....)$,) {
	my $block = [ @rule[9..12] ];

	# 0 1 2
	# 3 4 5
	# 6 7 8
	$rules{3}{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(0 1 2 3 4 5 6 7 8)]} = $block; # 0
	$rules{3}{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(2 1 0 5 4 3 8 7 6)]} = $block; # flip |
	$rules{3}{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(6 7 8 3 4 5 0 1 2)]} = $block; # flip -

	$rules{3}{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(2 5 8 1 4 7 0 3 6)]} = $block; # 90 ccw
	$rules{3}{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(8 5 2 7 4 1 6 3 0)]} = $block; # flip |
	$rules{3}{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(0 3 6 1 4 7 2 5 8)]} = $block; # flip -

	$rules{3}{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(8 7 6 5 4 3 2 1 0)]} = $block; # 180
	$rules{3}{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(6 7 8 3 4 5 0 1 2)]} = $block; # |
	$rules{3}{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(2 1 0 5 4 3 8 7 6)]} = $block; # -

	$rules{3}{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(6 3 0 7 4 1 8 5 2)]} = $block; # 90 cw
	$rules{3}{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(0 3 6 1 4 7 2 5 8)]} = $block; # |
	$rules{3}{sprintf "%s%s%s/%s%s%s/%s%s%s", @rule[qw(8 5 2 7 4 1 6 3 0)]} = $block; # -
	
    }
    else {
	die "unhandled rule [$_]\n";
    }
}

#print Data::Dumper->Dump([ \%rules ], [qw(rules)]);
#print Data::Dumper->Dump([ $size, \@art ], [qw(size art)]);

my @pixels_on;

push @pixels_on, 0;
for my $line (@art) {
    $pixels_on[-1] += $line =~ y/#/#/;
}

my $iter = 18;
while ($iter-->0) {
    #printf "Doing iteration...\n";
    my @new;
    my $blocksize;
    
    if (@art % 2 == 0) {
	$blocksize = 2;
    }
    elsif (@art % 3 == 0) {
	$blocksize = 3;
    }
    else {
	die sprintf "Weird size %d\n", 0+@art;
    }

    my @pos = map { $_ * $blocksize } 0 .. @art/$blocksize-1;

    for my $y (@pos) {
	my @lines = ('') x ($blocksize+1);
	for my $x (@pos) {
	    my $block_in = join "/", map { substr $art[$y+$_], $x, $blocksize } 0 .. $blocksize-1;
	    my $block_out = $rules{$blocksize}{$block_in};
	    unless ($block_out) {
		die sprintf "no mapping for [%s] in rules %d\n", $block_in, $blocksize;
	    }
	    for my $block_y (0 .. $blocksize) {
		$lines[$block_y] .=  $block_out->[$block_y];
	    }
	}
	push @new, @lines;
    }

    @art = @new;

    push @pixels_on, 0;
    for my $line (@art) {
	$pixels_on[-1] += $line =~ y/#/#/;
    }

    #print Data::Dumper->Dump([ \@art, 0+@art ], [qw(art size)]);
    #printf "\n";
}

printf "Solution 1: %d pixels are on\n", $pixels_on[5];
printf "Solution 2: %d pixels are on\n", $pixels_on[18];
