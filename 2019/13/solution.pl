#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;
use open ':locale';
use Term::ReadLine;

use Data::Dumper;

my $term = Term::ReadLine->new("input");

my $solution1;
my $solution2;

my @code;

while (<>) {
    chomp;
    push @code, split /,/;
}

my $program = Intcode->new(@code);

$program->config(on_output => sub {
		     my($self,$output) = @_;
		     $self->add_output($output);
		     # printf "output: %s\n", $output;
		     my @out = $self->get_output(3,1);
		     if (@out) {
			 my($x_pos, $y_pos, $value) = @out;
			 if ($x_pos == -1 && $y_pos == 0) {
			     $self->{__score} = $value;
			 }
			 else {
			     $self->{__screen}{$y_pos}{$x_pos} = $value;
			     $self->{__min_x} = $x_pos if $self->{__min_x} > $x_pos;
			     $self->{__max_x} = $x_pos if $self->{__max_x} < $x_pos;
			     $self->{__min_y} = $y_pos if $self->{__min_y} > $y_pos;
			     $self->{__max_y} = $y_pos if $self->{__max_y} < $y_pos;
			     if ($value == 3) { # paddle
				 $self->{__pad_x} = $x_pos;
				 $self->{__pad_y} = $y_pos;
			     }
			     elsif ($value == 4) { # ball
				 my $lx = $self->{__ball_x};
				 my $ly = $self->{__ball_y};
				 $self->{__ball_x} = $x_pos;
				 $self->{__ball_y} = $y_pos;
				 if ($lx && $ly) {
				     if ($lx < $x_pos) {
					 $self->{__ball_dx} = 1;
				     }
				     elsif ($lx > $x_pos) {
					 $self->{__ball_dx} = -1;
				     }
				 }

			     }
			 }
		     }
		 },
		 on_exit => sub {
		     my($self) = @_;
		     $self->set_output($self->{__screen});
		 }
		);

my($screen1) = $program->run();

for my $y (keys %$screen1) {
    for my $x (keys %{$screen1->{$y}}) {
	$solution1++ if $screen1->{$y}{$x} == 2;
    }
}

printf "Solution 1: %s\n", $solution1;

#                Wall         Block        Paddle       Ball
my @tile = (" ", chr(0x25A9), chr(0x25a2), chr(0x2015), chr(0x25cf));

sub draw_disp {
    my($self) = @_;
    printf "\e[H";
    for my $y ($self->{__min_y} .. $self->{__max_y}) {
	for my $x ($self->{__min_x} .. $self->{__max_x}) {
	    printf "%1s", $tile[$self->{__screen}{$y}{$x}] || '?';
	}
	printf "\e[K\n";
    }
    printf "\e[J";
    printf "Score: %s\n", $self->{__score};
}

$program->config(on_init => sub {
		     my($self) = @_;
		     $self->{_mem}[0] = 2; # free coins!
		     $self->{__ball_dx} = 1;
		     $self->{__ball_dy} = 1;
		 },
		 on_input => sub {
		     my($self,$input_p) = @_;
		     draw_disp($self);
		     $self->{__round}++;
		     my $joy = 0;
		     my($bx) = $self->{__ball_x};
		     my($dx) = $self->{__ball_dx};
		     my($px) = $self->{__pad_x};

		     if ($dx > 0) {
			 $joy = 1;
			 $joy = 0 if $px >= $bx;
		     }
		     elsif ($dx < 0) {
			 $joy = -1;
			 $joy = 0 if $px <= $bx;
		     }

		     # my $ans = $term->readline("move($joy)>");
		     return 0+$joy;
		 },
		 on_exit => sub {
		     my($self) = @_;
		     draw_disp($self);
		     $self->set_output($self->{__score}, $self->{__round});
		 }
		);

my(@ret2) = $program->run();

$solution2 = join " ", @ret2;

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

sub get_input {
    my($self) = @_;
    my $input_p = $self->{input_p};
    my $input;

    if ($self->{on_input}) {
	$input = $self->{on_input}($self,$input_p);
    }
    elsif ($self->have_input) {
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
    $self->{_break} = 0;
    while (!$self->{_break}) {
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
	    $input = $self->get_input();
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
