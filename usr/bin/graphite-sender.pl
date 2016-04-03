#!/usr/bin/perl

use strict;
use warnings;

use v5.10;

use Socket;
use Config::Simple;

my $conf_file = "/etc/graphite-sender.conf";

my %cfg;
my %conf;

my %conf_default = (
    'host' => 'graphite',
    'port' => '2003',
    'script_dir' => '/usr/lib/graphite-sender/',
    'cache_dir' => '/var/cache/graphite-sender/'
    );

Config::Simple->import_from($conf_file, \%conf);

foreach my $i (keys %conf_default) {
    if (defined ($conf{"default.$i"})) {
        $conf{"$i"} = $conf{"default.$i"};
    } else {
        $conf{"$i"} = $conf_default{"$i"}
    }
}

my $prefix = `hostname`;
chomp($prefix);

my $start_time = time();

opendir(DIR, $conf{'script_dir'}) ||
    die "Can't open dir $conf{'script_dir'}: $!\n";

my @scripts = grep {
    -f "$conf{'script_dir'}/$_" && -x "$conf{'script_dir'}/$_"
} readdir(DIR);

close(DIR);

my @points;

foreach my $script (@scripts) {
    if (my $name = ($script =~ /^([\w\d_-]+).?[\w\d_-]*$/)[0]) {
        open(OUT, "$conf{'script_dir'}/$script |") || next;

        while (<OUT>) {
            chomp;
            my $ts = time();
            push(@points, "$prefix.$name.$_ $ts\n");
        }
    }
}

my $need_cache = 0;
my $not_sent_cache = 0;

socket(SOCK, PF_INET, SOCK_STREAM, getprotobyname('tcp'));

my $addr;

if (my $ip = inet_aton($conf{'host'})){
    $addr = sockaddr_in($conf{'port'}, $ip);
} else {
    $need_cache = 1;
}

if ($need_cache == 0 && connect(SOCK, $addr)) {
    foreach my $point (@points) {
        if (!send(SOCK, $point, 0)) {
            $need_cache = 1;
            last;
        }
    }

    if ($need_cache == 0) {
        opendir(CACHE_DIR, $conf{'cache_dir'}) ||
            die "Can't open dir $conf{'cache_dir'}: $!\n";

        my @cached = grep {
            -f "$conf{'cache_dir'}/$_" && -e "$conf{'cache_dir'}/$_"
        } readdir(CACHE_DIR);
        close(CACHE_DIR);

        foreach my $cache (@cached) {
            open(CACHE, '<', "$conf{'cache_dir'}/$cache") || next;
            while (<CACHE>) {
                print "   -> $_";
                if (!send(SOCK, $_, 0)) {
                    $not_sent_cache = 1;
                    last;
                }
            }
            if ($not_sent_cache == 0) {
                unlink("$conf{'cache_dir'}/$cache");
            }
            close(CACHE);
        }
    }
    close(SOCK);
} else {
    $need_cache = 1;
}

if ($need_cache == 1) {
    open(CACHE, '>', "$conf{'cache_dir'}/$start_time")
        or die "Can't open file $conf{'cache_dir'}/$start_time: $!\n";
    print CACHE @points;
    close(CACHE);
}
