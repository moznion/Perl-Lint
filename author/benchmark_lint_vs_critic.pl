#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Benchmark qw/cmpthese/;
use Perl::Critic;
use Perl::Lint qw/lint/;

my $pc = Perl::Critic->new(-severity => 'brutal');

my $critic = sub {
    $pc->critique($0);
};

my $lint = sub {
    lint($0);
};

cmpthese(
    -1 => {
        'Perl::Critic' => $critic,
        'Perl::Lint' => $lint,
    },
);

