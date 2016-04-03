#!/usr/bin/perl

use strict;
use warnings;

use v5.10;

my $df = 'df |';
    
open(FD, $df) || die "Can't exec '$df': $!\n";

my @F;

my $p;

while (<FD>) {
    $_ =~ s/^\s+(.*)/$1/;
    @F = split /\s+/;

    if ($F[1] =~ m/^\d+$/){
	$p = $F[5];
	$p =~ s!^/$!rootfs!;
	$p =~ s!^/!!;
	$p =~ s!/!_!g;

	say "$p.used " . $F[2] * 1024;
	say "$p.free " . $F[3] * 1024;
    }
}

close(FD);
