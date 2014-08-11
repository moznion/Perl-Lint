#!perl

use strict;
use warnings;
use Perl::Lint::Policy::Subroutines::ProhibitNestedSubs;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Subroutines::ProhibitNestedSubs';

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
sub foo { my $bar = sub { 1 } }
sub foo { } sub bar { }

===
--- dscr: Basic failure
--- failures: 2
--- params:
--- input
sub foo { sub bar { 1 } }
sub foo { if (1) { do { sub bar { 1 } } } }

===
--- dscr: Subroutine declarations inside scheduled blocks used for lexical scope restriction.
--- failures: 0
--- params:
--- input
CHECK {
    my $foo = 1;

    sub bar { return $foo }
}

===
--- dscr: Scheduled blocks inside subroutine declarations.
--- failures: 0
--- params:
--- input
sub quack {
    state $foo;

    UNITCHECK {
        $foo = 1;
    }
}

===
--- dscr: Subroutine declarations inside scheduled blocks inside subroutine declarations.
--- failures: 1
--- params:
--- input
sub quack {
    INIT {
        my $foo = 1;

        sub bar { return $foo }
    }
}
