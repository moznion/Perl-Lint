#!perl

use strict;
use warnings;
use Perl::Lint::Policy::Subroutines::ProhibitSubroutinePrototypes;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Subroutines::ProhibitSubroutinePrototypes';

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
--- dscr: simple failure
--- failures: 2
--- params:
--- input
sub my_sub1 ($@) {}
sub my_sub2 (@@) {}

===
--- dscr: simple success
--- failures: 0
--- params:
--- input
sub my_sub1 {}
sub my_sub1 {}

