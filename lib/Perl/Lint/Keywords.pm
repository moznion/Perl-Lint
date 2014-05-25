package Perl::Lint::Keywords;
use strict;
use warnings;
use B::Keywords;
use parent qw/Exporter/;
our @EXPORT = qw/is_perl_builtin is_perl_bareword/;

my $builtin_func_map = {};
for my $func (@B::Keywords::Functions) {
    $builtin_func_map->{$func} = 1;
}

my $bareword_map = {};
for my $bareword (@B::Keywords::Barewords) {
    $bareword_map->{$bareword} = 1;
}

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

1;

