#!/usr/bin/perl

use strict;
use warnings;

use v5.10;

my $file = '/proc/loadavg';

open(FD, $file) || die "Can't open '$file': $!\n";

while (<FD>) {
    if ($_ =~ m!(\d+\.\d+) (\d+\.\d+) (\d+\.\d+) (\d+)/(\d+)!) {
        say "la1 $1";
        say "la5 $2";
        say "la15 $3";
        say "run_proc $4";
        say "total_proc $5";
    }
}

close(FD);
