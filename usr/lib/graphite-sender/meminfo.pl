#!/usr/bin/perl

use strict;
use warnings;

use v5.10;

my $file = '/proc/meminfo';

open(FD, $file) || die "Can't open '$file': $!\n";

while (<FD>) {
    if ($_ =~ m/([\w\d]+):\s+(\d+)\skB/) {
        say "$1 " . $2 * 1024;
    }
}

close(FD);
