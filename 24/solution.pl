#! /usr/bin/perl

use strict;

use Data::Dumper;
$Data::Dumper::Sortkeys = $Data::Dumper::Indent = 1;

@ARGV = qw(input) unless @ARGV;

my @input;

while (<>) {
    chomp;
    if (m,^(\d+)/(\d+),) {
	push @input, [ $1, $2, 0 ];
    }
}

sub find_max_bridge {
    my($ports) = @_;
    my $sum;

    my @unused = grep { !$used{$->[2]} } @$ports;

    for my $port (@unused) {
	$port->[2] = 1;
	my $sub = find_max_bridge($ports);
	
	
    }

    
    
    
    
    

    

}
