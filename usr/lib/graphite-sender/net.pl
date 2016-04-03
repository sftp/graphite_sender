#!/usr/bin/perl

use strict;
use warnings;

use v5.10;

my $file = '/proc/net/dev';

open(FD, $file) || die "Can't open '$file': $!\n";

my @F;

my $r;
my $t;

while (<FD>) {
    $_ =~ s/^\s+(.*)/$1/;
    @F = split /\s+/;

    if ($F[0]=~m/(\w+\d+[\w\d]*):/) {
        $r="$1.rx";
        $t="$1.tx";

        say "$r.bytes $F[1]";
        say "$r.packets $F[2]";
        say "$r.errs $F[3]";
        say "$r.drop $F[4]";
        say "$r.fifo $F[5]";
        say "$r.frame $F[6]";
        say "$r.compressed $F[7]";
        say "$r.multicast $F[8]";

        say "$t.bytes $F[9]";
        say "$t.packets $F[10]";
        say "$t.errs $F[11]";
        say "$t.drop $F[12]";
        say "$t.fifo $F[13]";
        say "$t.colls $F[14]";
        say "$t.carrier $F[15]";
        say "$t.compressed $F[16]"}
}

close(FD);
