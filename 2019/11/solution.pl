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

my @dir = ([  0, -1, "UP"],
	   [  1,  0, "RIGHT" ],
	   [  0,  1, "DOWN" ],
	   [ -1,  0, "LEFT" ],
	  );

$program->config(on_input => sub {
		     my($self,$input_p) = @_;
		     my $robot_x = 0+$self->{__robot_x};
		     my $robot_y = 0+$self->{__robot_y};
		     return $self->{__robot_map}{$robot_y}{$robot_x} eq '#' ? 1 : 0;
		 },
		 on_output => sub {
		     my($self,$output) = @_;
		     if ($self->{__robot_out}++ % 2) {
			 if ($output) {
			     $self->{__robot_dir} = ($self->{__robot_dir} + 1) % 4;
			 }
			 else {
			     $self->{__robot_dir} = ($self->{__robot_dir} + 3) % 4;
			 }
			 my($xi,$yi,$dn) = @{$dir[$self->{__robot_dir}]};
			 $self->{__robot_x} += $xi;
			 $self->{__robot_y} += $yi;
			 # printf "  Moving %s to %d,%d\n", $dn, $self->{__robot_x}, $self->{__robot_y};
		     }
		     else {
			 my $robot_x = $self->{__robot_x};
			 my $robot_y = $self->{__robot_y};
			 if ($output) {
			     # printf "Painting\n";
			     $self->{__robot_map}{$robot_y}{$robot_x} = '#';
			 }
			 else {
			     # printf "Skipping\n";
			     $self->{__robot_map}{$robot_y}{$robot_x} = '.';
			 }
		     }
		 },
		 on_exit => sub {
		     my($self) = @_;
		     $self->set_output($self->{__robot_map});
		 }
		);

my($map1) = $program->run();

for my $y (keys %$map1) {
    for my $x (keys %{$map1->{$y}}) {
	$solution1++ if defined $map1->{$y}{$x};
    }
}

printf "Solution 1: %s\n", $solution1;

$program->config(on_init => sub {
		     my($self) = @_;
		     $self->{__robot_map}{0}{0} = '#';
		 });

my($map2) = $program->run();

my($min_x, $max_x, $min_y, $max_y) = (0) x 4;
for my $y (keys %$map2) {
    for my $x (keys %{$map2->{$y}}) {
	if (defined $map2->{$y}{$x}) {
	    $min_x = $x if $x < $min_x;
	    $min_y = $y if $y < $min_y;
	    $max_x = $x if $x > $max_x;
	    $max_y = $y if $y > $max_y;
	}
    }
}

$solution2 = "$min_x,$min_y - $max_x,$max_y\n";
for my $y ($min_y .. $max_y) {
    for my $x ($min_x .. $max_x) {
	unless ($x || $y) {
	    $solution2 .= "\e[42m";
	}
	$solution2 .= $map2->{$y}{$x} || '.';
	unless ($x || $y) {
	    $solution2 .= "\e[m";
	}
    }
    $solution2 .= "\n";
}

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

sub output {
    my($self,$output) = @_;
    if ($self->{on_output}) {
	$self->{on_output}($self,$output);
    }
    else {
	$self->add_output($output);
	# printf " output: %s\n", $output;
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
