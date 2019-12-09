#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;
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

my @ret = $program->run(1);

$solution1 = "@ret";

printf "Solution 1: %s\n", $solution1;

my @ret = $program->run(2);

$solution2 = "@ret";

printf "Solution 2: %s\n", $solution2;

exit;

sub permute_run {
    my($list,$proc,@perm) = @_;
    if (@$list) {
	for my $i (0 .. @$list-1) {
	    my @sub_list = (@{$list}[0..$i-1], @{$list}[$i+1 .. @$list-1]);
	    permute_run(\@sub_list, $proc, @perm, $list->[$i]);
	}
    }
    else {
	$proc->(@perm);
    }
}

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
    $self->set_output();
    $self->set_input( @input );

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

    $self->{op} = $op % 100;
    $self->{op_mode} = [];
    $self->{op_pp} = 0;

    $op = int($op/100);
    while ($op) {
	push @{$self->{op_mode}}, $op % 10;
	$op = int($op/10);
    }
    return $self->{op};
}

sub get_addr_op {
    my($self) = @_;
    my $ip = $self->{_ip}++;
    my $addr = $self->{_mem}[$ip];
    my $pp = $self->{op_pp}++;
    my $mode = $self->{op_mode}[$pp];
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
    if ($self->have_input) {
	$input = $self->{input}[$input_p];
    }
    else {
	$input = $term->readline("input[$input_p]> ");
	push @{$self->{input}}, $input;
    }
    # printf " input: %s\n", $input;

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

sub output {
    my($self,$output) = @_;
    if ($self->{output_hook}) {
	$self->{output_hook}($self,$output);
    }
    else {
	$self->add_output($output);
#	printf " output: %s\n", $output;
    }
}


sub error {
    my($self,$error) = @_;
    my $op = $self->{op};
    my $ip = $self->{_ip};
#    print Dumper $self;
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
	    if ($self->{break_on_input_wait} && !$self->have_input) {
		# printf "Break at %d!\n", $restart_ip;
		$self->{_break}++;
		last;
	    }
	    my $input = $self->get_input();
	    $self->put_param($input);
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

    return @{$self->{output}};
}
