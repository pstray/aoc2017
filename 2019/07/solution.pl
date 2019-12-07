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
my $ret;

my @max_phase;

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

permute_run([0..4],
	    sub {
		my($phase_a,$phase_b,$phase_c,$phase_d,$phase_e) = @_;
		($ret) = $program->run($phase_a, 0);
		($ret) = $program->run($phase_b, $ret);
		($ret) = $program->run($phase_c, $ret);
		($ret) = $program->run($phase_d, $ret);
		($ret) = $program->run($phase_e, $ret);

		if ($ret > $solution1) {
		    $solution1 = $ret;
		    @max_phase =
		      ($phase_a, $phase_b, $phase_c, $phase_d, $phase_e);
		    printf "new max ($ret) at @max_phase\n";
		}
	    }
	   );

printf "Solution 1: %s\n", $solution1;

$program->config(break_on_input_wait => 1,
		 output_hook => sub {
		     $_[0]->set_output($_[1]);
		 }
		);

my $amp_a = $program->clone();
my $amp_b = $program->clone();
my $amp_c = $program->clone();
my $amp_d = $program->clone();
my $amp_e = $program->clone();

permute_run([5..9],
	    sub {
		my($phase_a,$phase_b,$phase_c,$phase_d,$phase_e) = @_;
		# print "trying...\n";

		$amp_a->init($phase_a);
		$amp_b->init($phase_b);
		$amp_c->init($phase_c);
		$amp_d->init($phase_d);
		$amp_e->init($phase_e);

		$ret = 0;

		while (1) {
		    #print "Starting A\n";
		    ($ret) = $amp_a->cont($ret);
		    #print "Starting B\n";
		    ($ret) = $amp_b->cont($ret);
		    #print "Starting C\n";
		    ($ret) = $amp_c->cont($ret);
		    #print "Starting D\n";
		    ($ret) = $amp_d->cont($ret);
		    #print "Starting E\n";
		    ($ret) = $amp_e->cont($ret);
		    last if $amp_e->finished;
		}
		# printf "   got $ret\n";

		if ($ret > $solution2) {
		    $solution2 = $ret;
		    @max_phase =
		      ($phase_a, $phase_b, $phase_c, $phase_d, $phase_e);
		    printf "new max ($ret) at @max_phase\n";
		}

	    }
	   );

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

sub get_addr {
    my($self) = @_;
    my $ip = $self->{_ip}++;
    my $addr = $self->{_mem}[$ip];
    return $addr;
}

sub get_param {
    my($self) = @_;
    my $addr = $self->get_addr();
    my $pp = $self->{op_pp}++;
    my $mode = $self->{op_mode}[$pp];
    my $param;
    #print "  p[$pp]";
    if ($mode == 0) { # ref
	#print "  = mem[$addr]";
	$param = $self->{_mem}[$addr];
    }
    elsif ($mode == 1) { # immed
	$param = $addr;
    }
    #print " = $param\n";
    return $param;
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
    my($self) = @_;
    my $op = $self->{op};
    my $ip = $self->{_ip};
#    print Dumper $self;
    warn "Kablam! ip = $ip, op = $op\n";

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
	    my $a3 = $self->get_addr();
	    # printf "[%s] = %s + %s\n", $a3, $p1, $p2;
	    $self->{_mem}[$a3] = $p1 + $p2;
	}
	elsif ($op == 2) { # *
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    my $a3 = $self->get_addr();
	    # printf "[%s] = %s * %s\n", $a3, $p1, $p2;
	    $self->{_mem}[$a3] = $p1 * $p2;
	}
	elsif ($op == 3) { # input
	    if ($self->{break_on_input_wait} && !$self->have_input) {
		# printf "Break at %d!\n", $restart_ip;
		$self->{_break}++;
		last;
	    }
	    my $a1 = $self->get_addr();
	    my $input = $self->get_input();
	    $self->{_mem}[$a1] = $input;
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
	    my $a3 = $self->get_addr();
	    $self->{_mem}[$a3] = $p1 < $p2 ? 1 : 0;
	}
	elsif ($op == 8) { # =
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    my $a3 = $self->get_addr();
	    $self->{_mem}[$a3] = $p1 == $p2 ? 1 : 0;
	}
	elsif ($op == 99) {
	    $self->{_finished}++;
	    last;
	}
	else {
	    $self->error();
	    return;
	}
    }

    if ($self->{_break}) {
	$self->{_ip} = $restart_ip;
    }

    return @{$self->{output}};
}
