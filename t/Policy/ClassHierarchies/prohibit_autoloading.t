#!perl

use strict;
use warnings;
use Perl::Lint::Policy::ClassHierarchies::ProhibitAutoloading;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ClassHierarchies::ProhibitAutoloading';

filters {
    params => [qw/eval/], # TODO wrong!
};

for my $block (blocks) {
    my $violations = fetch_violations($class_name, $block->input, $block->params);
    is scalar @$violations, $block->failures, $block->dscr;
}

done_testing;

__DATA__

===
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
sub autoload {}
my $AUTOLOAD = 'foo';
our @AUTOLOAD = qw(nuts);

===
--- dscr: Empty AUTOLOAD()
--- failures: 1
--- params:
--- input
sub AUTOLOAD {}

===
--- dscr: AUTOLOAD() with code
--- failures: 1
--- params:
--- input
sub AUTOLOAD {
     $foo, $bar = @_;
     return $baz;
}

