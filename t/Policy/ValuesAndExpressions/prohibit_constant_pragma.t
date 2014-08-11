#!perl

use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitConstantPragma;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitConstantPragma';

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
my $FOO = 42;
local BAR = 24;
our $NUTS = 16;

===
--- dscr: Basic failure
--- failures: 2
--- params:
--- input
use constant FOO => 42;
use constant BAR => 24;

