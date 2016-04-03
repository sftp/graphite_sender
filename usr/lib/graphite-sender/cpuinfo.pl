#!/usr/bin/perl

use strict;
use warnings;

use v5.10;

my $file = '/proc/cpuinfo';

open(FD, $file) || die "Can't open '$file': $!\n";

my $c;

while (<FD>) {
    if (m/^processor\s+:\s+(\d+)/) {
	$c="cpu$1";
    } elsif (m/^cpu MHz\s+:\s+(\d+.?\d*)/) {
	say "MHz.$c $1";
    }
}

close(FD);
