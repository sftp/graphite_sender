#!/usr/bin/perl

use strict;
use warnings;

use v5.10;

my $sens = 'sensors |';

open(FD, $sens) || die "Can't exec '$sens': $!\n";

my $m;
my $k;
my $v;

while (<FD>) {
    if ($_ =~ m/^([\w\d_-]+$)/) {
        $m = $1;
        $m=~s/-/_/g;
    }

    if ($_ =~ m/(.*):\s+(\+?[\d\.]+)/) {
        $k = lc($1);
        $v = $2;
        $k =~ s/^\s+//;
        $k =~ s/[\s\.]/_/g;
        $k =~ s/\+/plus_/;

        say"$m.$k $v"
    }
}

close(FD);
