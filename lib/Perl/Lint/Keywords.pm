package Perl::Lint::Keywords;
use strict;
use warnings;
use B::Keywords;
use parent qw/Exporter/;
our @EXPORT = qw/is_perl_builtin is_perl_bareword is_perl_pragma/;

my $builtin_func_map = {};
for my $func (@B::Keywords::Functions) {
    $builtin_func_map->{$func} = 1;
}

my $bareword_map = {};
for my $bareword (@B::Keywords::Barewords) {
    $bareword_map->{$bareword} = 1;
}

my $pragma_map = {
    attributes           => 1,
    autodie              => 1,
    autouse              => 1,
    base                 => 1,
    bigint               => 1,
    bignum               => 1,
    bigrat               => 1,
    blib                 => 1,
    bytes                => 1,
    charnames            => 1,
    constant             => 1,
    diagnostics          => 1,
    encoding             => 1,
    feature              => 1,
    fields               => 1,
    filetest             => 1,
    if                   => 1,
    integer              => 1,
    less                 => 1,
    lib                  => 1,
    locale               => 1,
    mro                  => 1,
    open                 => 1,
    ops                  => 1,
    overload             => 1,
    overloading          => 1,
    parent               => 1,
    re                   => 1,
    sigtrap              => 1,
    sort                 => 1,
    strict               => 1,
    subs                 => 1,
    threads              => 1,
    'threads::shared'    => 1,
    utf8                 => 1,
    vars                 => 1,
    vmsish               => 1,
    warnings             => 1,
    'warnings::register' => 1,
};

sub is_perl_builtin {
    my $key = shift;
    return if !$key;

    return exists $builtin_func_map->{$key};
}

sub is_perl_bareword {
    my $key = shift;
    return if !$key;

    return exists $bareword_map->{$key};
}

sub is_perl_pragma {
    my $key = shift;
    return if !$key;

    return exists $pragma_map->{$key};
}

1;

