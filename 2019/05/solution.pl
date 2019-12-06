#! /usr/bin/perl
#
#    $Id$
#
# Copyright (C) 2019 by Peder Stray <peder@wintermute>
#

use strict;
use Term::ReadLine;

my $term = Term::ReadLine->new("input");

my $solution1;
my $solution2;

my @code;

while (<>) {
    chomp;
    push @code, split /,/;
}

my $program = Intcode->new(@code);

$solution1 = join " ", $program->run(1);
printf "Solution 1: %s\n", $solution1;

$solution2 = join " ", $program->run(5);
printf "Solution 2: %s\n", $solution2;

exit;

package Intcode;

use Data::Dumper;

sub new {
    my($self,@code) = @_;
    my $class = ref($self) || $self;
    $self = bless { code => \@code }, $class;
    return $self;
}

sub get_op {
    my($self) = @_;
    my $ip = $self->{ip}++;
    my $op = $self->{mem}[$ip];

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
    my $ip = $self->{ip}++;
    my $addr = $self->{mem}[$ip];
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
	$param = $self->{mem}[$addr];
    }
    elsif ($mode == 1) { # immed
	$param = $addr;
    }
    #print " = $param\n";
    return $param;
}

sub get_input {
    my($self) = @_;
    my $input_p = $self->{input_p}++;
    my $input;
    if (@{$self->{input}} > $input_p) {
	$input = $self->{input}[$input_p];
    }
    else {
	$input = $term->readline("input[$input_p]> ");
	push @{$self->{input}}, $input;
    }
    printf "input: %s\n", $input;
    return $input;
}

sub output {
    my($self,$output) = @_;
    push @{$self->{output}}, $output;
    printf "output: %s\n", $output;
}


sub error {
    my($self) = @_;
    my $op = $self->{op};
    my $ip = $self->{ip};
#    print Dumper $self;
    warn "Kablam! ip = $ip, op = $op\n";

}

sub run {
    my($self,@input) = @_;
    # copy code so we won't brake it
    $self->{mem} = [ @{$self->{code}} ];
    $self->{ip} = 0;
    $self->{output} = [];
    $self->{input_p} = 0;
    $self->{input} = [ @input ];

    while (1) {
	my $op = $self->get_op();

	if ($op == 1) { # +
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    my $a3 = $self->get_addr();
	    $self->{mem}[$a3] = $p1 + $p2;
	}
	elsif ($op == 2) { # *
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    my $a3 = $self->get_addr();
	    $self->{mem}[$a3] = $p1 * $p2;
	}
	elsif ($op == 3) { # input
	    my $a1 = $self->get_addr();
	    my $input = $self->get_input();
	    $self->{mem}[$a1] = $input;
	}
	elsif ($op == 4) { # output
	    my $p1 = $self->get_param();
	    $self->output($p1);
	}
	elsif ($op == 5) { # jump if true
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    if ($p1) {
		$self->{ip} = $p2;
	    }
	}
	elsif ($op == 6) { # jump if false
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    unless ($p1) {
		$self->{ip} = $p2;
	    }
	}
	elsif ($op == 7) { # <
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    my $a3 = $self->get_addr();
	    $self->{mem}[$a3] = $p1 < $p2 ? 1 : 0;
	}
	elsif ($op == 8) { # =
	    my $p1 = $self->get_param();
	    my $p2 = $self->get_param();
	    my $a3 = $self->get_addr();
	    $self->{mem}[$a3] = $p1 == $p2 ? 1 : 0;
	}
	elsif ($op == 99) {
	    last;
	}
	else {
	    $self->error();
	    return;
	}
    }
    return @{$self->{output}};
}
