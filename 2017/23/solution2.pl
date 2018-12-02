#! /usr/bin/perl

my $b = 105700;
my $h = 0;
while ($b <= 122700) {
    my $max = $b-1;
    my $f = 1;
    for my $d (2 .. $max) {
	next if $b % $d;
	$f = 0;
	last;
    }
    $h++ unless $f;
    $b += 17;
}

printf "Solution 2: h=%d\n", $h;
