#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@kraftcert.no>
#

use strict;

use open ':locale';
use Term::ReadLine;
use Time::HiRes qw(sleep);

use Data::Dumper;

$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

$| = 1;

my $term = Term::ReadLine->new("input");

my $solution1;
my $solution2;

my @code;

while (<>) {
    chomp;
    push @code, split /,/;
}

my $program = Intcode->new(@code);
$program->config(ascii => 1,
		);

my(@ret1) = $program->run("south
west
take asterisk
east
north
east
north
north
take mutex
north
take prime number
south
south
east
north
take mug
south
west
south
east
east
south
east
east
north
");

printf "Solution 1: %s\n", @ret1, $solution1;

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

    if ($self->{ascii}) {
	@input = map { map { ord } split //, $_ } @input;
    }
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
    return $self->{_exit} ? 1 : 0;
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

sub next_input {
    my($self) = @_;
    $self->{input}[$self->{input_p}++];
}

sub get_input {
    my($self) = @_;
    my $input_p = $self->{input_p};
    my $input;

    if ($self->have_input) {
	$input = $self->next_input()
    }
    else {
	if ($self->{break_on_input_wait}) {
	    $self->{_break}++;
	    return;
	}
	elsif (exists $self->{input_empty_value}) {
	    $input = $self->{input_empty_value};
	}
	else {
	    $input = $term->readline("input[$input_p]> ");
	    my @input;

	    if ($self->{ascii}) {
		@input = map { ord } split //, "$input\n";
	    }
	    else {
		@input = ($input);
	    }
	    printf "Adding: @input\n";
	    $self->add_input(@input);
	    $input = $self->next_input();
	}
    }
    # printf "  Returning: %s from c=%d\n", $input, $self->{input}[0];
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
    elsif ($self->{ascii}) {
	if ($output < 256) {
	    printf "%c", $output
	}
	else {
	    printf "%s", $output;
	    $self->add_output($output);
	}
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

    # printf "  at %d\n", $self->{ip};
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
	    $self->{_exit}++;
	}
	else {
	    $self->error("Unknown opcode");
	    return;
	}

	last if $self->{step};
    }

    if ($self->{_break}) {
	$self->{_ip} = $restart_ip;
    }

    if ($self->{on_exit}) {
	$self->{on_exit}($self);
    }

    return @{$self->{output}};
}
