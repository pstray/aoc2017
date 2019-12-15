#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;
use open ':locale';
use Term::ReadLine;
use Time::HiRes qw(sleep);

use Data::Dumper;

$| = 1;

my $term = Term::ReadLine->new("input");

my $solution1;
my $solution2;

my @code;

while (<>) {
    chomp;
    push @code, split /,/;
}

my %tile_map =
  ( D => chr(0xe70e),
    '.' => chr(0xb7),
    'O' => chr(0x2299),
    '#' => chr(0x2593),
    '?' => chr(0x2573),
  );

sub draw_map {
    my($self,$info) = @_;
    printf "\e[H";
    my $min_y = 0+$self->{__min_y};
    my $max_y = 0+$self->{__max_y};
    my $min_x = 0+$self->{__min_x};
    my $max_x = 0+$self->{__max_x};
    printf "MAP (%d,%d) (%d,%d)\e[K\n", $min_x, $min_y, $max_x, $max_y;
    for my $y ($min_y-1 .. $max_y+1) {
	for my $x ($min_x-1 .. $max_x+1) {
	    my $color = 3;
	    my $tile = $self->{__map}{$y}{$x};
	    if ($self->{__check}{"$x,$y"}) {
		$color = 5;
	    }
	    elsif ($tile eq '#') {
		$color = 202;
	    }
	    elsif ($tile eq '.') {
		my $v = $self->{__visit}{$y}{$x};
		$color = 255 - $v;
		$color = 1 if $color < 232;
	    }
	    elsif ($tile eq 'O') {
		$color = 14;
	    }
	    elsif ($tile eq 'D') {
		$color = 10;
	    }
	    elsif ($self->{__check}{"$x,$y"}) {
		$color = 5;
	    }
	    printf "\e[38;5;%sm%1s", $color, $tile_map{$tile || '?'} || '?';
	}
	printf "\e[m\e[K\n";
    }
    printf "info: %s\e[K\n", $info;
    printf "\e[J";

}

sub draw_dist {
    my($self) = @_;
    printf "\e[H";
    my $min_y = 0+$self->{__min_y};
    my $max_y = 0+$self->{__max_y};
    my $min_x = 0+$self->{__min_x};
    my $max_x = 0+$self->{__max_x};
    printf "DIST (%d,%d) (%d,%d)\e[K\n", $min_x, $min_y, $max_x, $max_y;
    for my $y ($min_y-1 .. $max_y+1) {
	for my $x ($min_x-1 .. $max_x+1) {
	    my $color = 3;
	    my $tile = $self->{__map}{$y}{$x} || '?';
	    if ($self->{__check}{"$x,$y"}) {
		$color = 5;
	    }
	    elsif ($tile eq '#') {
		$color = 202;
	    }
	    elsif ($tile eq '.') {
		my $v = $self->{__visit}{$y}{$x};
		$color = 232 + $v;
		$color = 1 if $color > 255;
		$tile = $self->{__dist}{$y}{$x};
	    }
	    elsif ($tile eq 'O') {
		$color = 10;
		$tile = $self->{__dist}{$y}{$x};
	    }
	    elsif ($tile eq 'D') {
		$color = 4;
	    }
	    printf "\e[48;5;%sm%3s", $color, $tile;
	}
	printf "\e[m\e[K\n";
    }
    printf "\e[J";
}

sub next_pos {
    my($x,$y,$d) = @_;
    if ($d == 1) { # north
	$y--;
    }
    elsif ($d == 2) { # south
	$y++;
    }
    elsif ($d == 3) { # west
	$x--;
    }
    elsif ($d == 4) { # east
	$x++;
    }
    return ($x,$y);
}

my $program = Intcode->new(@code);

$program->config(on_output => sub {
		     my($self,$output) = @_;
		     my $dir = $self->{__droid_d};
		     my $ox = $self->{__droid_x};
		     my $oy = $self->{__droid_y};
		     my($x,$y) = next_pos($ox,$oy,$dir);

		     $self->{__min_y} = $y if $y < $self->{__min_y};
		     $self->{__max_y} = $y if $y > $self->{__max_y};
		     $self->{__min_x} = $x if $x < $self->{__min_x};
		     $self->{__max_x} = $x if $x > $self->{__max_x};

		     delete $self->{__check}{"$x,$y"};

		     if ($output == 0) {
			 # hit a wall
			 $self->{__map}{$y}{$x} = '#';
			 ($x,$y) = ($ox,$oy);
		     }
		     elsif ($output == 1 || $output == 2) {
			 $self->{__map}{$oy}{$ox} = '.'
			   if $self->{__map}{$oy}{$ox} eq 'D';
			 $self->{__visit}{$oy}{$ox}++;

			 $self->{__dist}{$y}{$x} ||=
			   $self->{__dist}{$oy}{$ox}+1;

			 $self->{__droid_x} = $x;
			 $self->{__droid_y} = $y;

			 if ($output == 1) {
			     $self->{__map}{$y}{$x} = 'D';
			 }
			 else {
			     $self->{__map}{$y}{$x} = 'O';
			     $self->{__oxy_x} = $x;
			     $self->{__oxy_y} = $y;
			     $self->add_output($self->{__dist}{$y}{$x});
			     $self->{_exit}++;
			 }
		     }

		     my @pri;
		     for my $d (1..4) {
			 my($nx,$ny) = next_pos($x,$y,$d);
			 my $tile = $self->{__map}{$ny}{$nx};
			 if ($tile eq '#' || $tile eq 'O') {
			     # skip it
			 }
			 elsif ($tile eq '.') {
			     push @pri, [ 10+$self->{__visit}{$ny}{$nx}, $d ];
			 }
			 else {
			     $self->{__check}{"$nx,$ny"}++;
			     push @pri, [ 0, $d ];
			 }
		     }
		     ($self->{__next_d}) = map { $_->[1] }
		       sort { $a->[0] <=> $b->[0] } @pri;

		     draw_map($self, "next(".$self->{__next_d}.")");
		     sleep 0.1;

		     $self->{_exit}++ unless keys %{$self->{__check}};
		 },
		 on_input => sub {
		     my($self) = @_;
		     my $input; # = $self->get_input();
		     $self->{__droid_d} = $input || $self->{__next_d};
		     return $self->{__droid_d};
		 },
		 on_init => sub {
		     my($self) = @_;
		     $self->{__droid_x} = 0;
		     $self->{__droid_y} = 0;
		     $self->{__map}{0}{0} = 'D';
		     $self->{__dist}{0}{0} = 0;
		     $self->{__next_d} = 1;
		     print "\e[H\e[2J";
		 },
		 on_exit => sub {
		     my($self) = @_;
		     my $x = $self->{__droid_x};
		     my $y = $self->{__droid_y};
		     # draw_dist($self);
		 }
		);

my(@ret1) = $program->run();
$solution1 = join " ", @ret1;

my(@ret2) = $program->cont();

my @flow = ([ $program->{__oxy_x}, $program->{__oxy_y} ]);
while (1) {
    my @next;
    for my $o (@flow) {
	my($x,$y) = @$o;
	$program->{__map}{$y}{$x} = 'O';
	for my $d (1..4) {
	    my($nx,$ny) = next_pos($x,$y,$d);
	    my $tile = $program->{__map}{$ny}{$nx};
	    next if $tile eq '#' || $tile eq 'O';
	    push @next, [ $nx, $ny ];
	}
    }
    draw_map($program, "time: $solution2");
    @flow = @next;
    last unless @flow;
    $solution2++;
    sleep 0.1;
}

printf "Solution 1: %s\n", $solution1;
printf "Solution 2: %s\n", $solution2;

exit;

package Intcode;

use Data::Dumper;

sub clone {
    my($self) = @_;
    my $class = ref($self);
    my $copy = bless { %$self }, $class;
    return $copy;
}

sub new {
    my($self,@code) = @_;
    my $class = ref($self) || $self;
    $self = bless { }, $class;
    if (ref $code[0]) {
	$self->config(shift @code);
    }
    if (@code) {
	$self->{code} = [@code];
    }
    unless ($self->{code}) {
	return undef;
    }
    return $self;
}

sub config {
    my($self,@config) = @_;
    my $config = $config[0];
    unless (ref $config) {
	$config = { @config };
    }
    for my $key (keys %$config) {
	$self->{$key} = $config->{$key};
    }
    return $self;
}

sub init {
    my($self,@input) = @_;

    # copy code so we won't brake it
    for my $key (keys %$self) {
	delete $self->{$key} if $key =~ /^_/;
    }
    $self->{_mem} = [ @{$self->{code}} ];
    $self->{_ip} = 0;
    $self->{_rb} = 0;

    $self->set_input( @input );
    $self->set_output();

    if ($self->{on_init}) {
	$self->{on_init}($self);
    }

    $self;
}

# ----

sub finished {
    my($self) = @_;
    return $self->{_finished} ? 1 : 0;
}

# ----

sub get_op {
    my($self) = @_;
    my $ip = $self->{_ip}++;
    my $op = $self->{_mem}[$ip];

    #print "ip = $ip, op = $op\n";

    $self->{_op} = $op % 100;
    $self->{_op_mode} = [];
    $self->{_op_pp} = 0;

    $op = int($op/100);
    while ($op) {
	push @{$self->{_op_mode}}, $op % 10;
	$op = int($op/10);
    }
    return $self->{_op};
}

sub get_addr_op {
    my($self) = @_;
    my $ip = $self->{_ip}++;
    my $addr = $self->{_mem}[$ip];
    my $pp = $self->{_op_pp}++;
    my $mode = $self->{_op_mode}[$pp];
    return ($ip,$addr,$mode);
}

sub get_param {
    my($self) = @_;
    my($ip,$addr,$mode) = $self->get_addr_op();
    my $param;
    #print "  p[$pp]";
    if ($mode == 0) { # ref
	#print "  = mem[$addr]";
	$param = $self->{_mem}[$addr];
    }
    elsif ($mode == 1) { # immed
	$param = $addr;
    }
    elsif ($mode == 2) {
	$param = $self->{_mem}[$self->{_rb} + $addr]
    }
    #print " = $param\n";
    return $param;
}

sub put_param {
    my($self,$value) = @_;
    my($ip,$addr,$mode) = $self->get_addr_op();
    #print "  p[$pp]";
    if ($mode == 0) { # ref
	#print "  = mem[$addr]";
	$self->{_mem}[$addr] = $value;
    }
    elsif ($mode == 1) { # immed
	$self->error("immed write");
    }
    elsif ($mode == 2) {
	$self->{_mem}[$self->{_rb} + $addr] = $value;
    }
    #print " = $param\n";
    return $value;
}

sub set_input {
    my($self,@input) = @_;
    $self->{input_p} = 0;
    $self->{input} = [ @input ];
}

sub add_input {
    my($self,@input) = @_;
    push @{$self->{input}}, @input;
}

sub have_input {
    my($self) = @_;
    return @{$self->{input}} > $self->{input_p};
}

sub input {
    my($self) = @_;
    my $input_p = $self->{input_p};
    my $input;
    if ($self->{on_input}) {
	$input = $self->{on_input}($self,$input_p);
    }
    else {
	$input = $self->get_input();
    }
}

sub get_input {
    my($self) = @_;
    my $input_p = $self->{input_p};
    my $input;

    if ($self->have_input) {
	$input = $self->{input}[$input_p];
    }
    else {
	if ($self->{break_on_input_wait}) {
	    $self->{_break}++;
	    return;
	}
	else {
	    $input = $term->readline("input[$input_p]> ");
	    push @{$self->{input}}, $input;
	}
    }
    $self->{input_p}++;
    return $input;
}

sub set_output {
    my($self,@output) = @_;
    $self->{output} = [ @output ];
}

sub add_output {
    my($self,@output) = @_;
    push @{$self->{output}}, @output;
}

sub num_output {
    my($self) = @_;
    return 0+@{$self->{output}};
}

sub get_output {
    my($self,$num,$if_enough) = @_;
    $num = 1 if $num < 1;
    if ($if_enough && @{$self->{output}} < $num) {
	return;
    }
    return splice @{$self->{output}}, 0, $num;
}

sub output {
    my($self,$output) = @_;
    if ($self->{on_output}) {
	$self->{on_output}($self,$output);
    }
    else {
	$self->add_output($output);
    }
}

sub error {
    my($self,$error) = @_;
    my $op = $self->{_op};
    my $ip = $self->{_ip};
    # print Dumper $self;
    die "Kablam! ip = $ip, op = $op, error = $error\n";
}

sub run {
    my($self,@input) = @_;
    $self->init(@input);
    return $self->cont();
}

sub cont {
    my($self,@input) = @_;
    my($restart_ip);

    $self->add_input(@input) if @input;

    # printf "  at %d\n", $self->{_ip};
    $self->{_break} = $self->{_exit} = 0;
    while (!($self->{_break} || $self->{_exit})) {
	$restart_ip = $self->{_ip};

	my $op = $self->get_op();

	if ($op == 1) { # +
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    # printf "[%s] = %s + %s\n", $a3, $p1, $p2;
	    $self->put_param($p1 + $p2);
	}
	elsif ($op == 2) { # *
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    # printf "[%s] = %s * %s\n", $a3, $p1, $p2;
	    $self->put_param($p1 * $p2);
	}
	elsif ($op == 3) { # input
	    my $input;
	    $input = $self->input();
	    $self->put_param($input) if defined $input;
	}
	elsif ($op == 4) { # output
	    my $p1 = $self->get_param();
	    $self->output($p1);
	}
	elsif ($op == 5) { # jump if true
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    if ($p1) {
		$self->{_ip} = $p2;
	    }
	}
	elsif ($op == 6) { # jump if false
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    unless ($p1) {
		$self->{_ip} = $p2;
	    }
	}
	elsif ($op == 7) { # <
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    $self->put_param($p1 < $p2 ? 1 : 0);
	}
	elsif ($op == 8) { # =
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    $self->put_param($p1 == $p2 ? 1 : 0);
	}
	elsif ($op == 9) {
	    my $p1 = $self->get_param();
	    $self->{_rb} += $p1;
	}
	elsif ($op == 99) {
	    $self->{_finished}++;
	    last;
	}
	else {
	    $self->error("Unknown opcode");
	    return;
	}
    }

    if ($self->{_break}) {
	$self->{_ip} = $restart_ip;
    }

    if ($self->{on_exit}) {
	$self->{on_exit}($self);
    }

    return @{$self->{output}};
}
