#!perl

use strict;
use warnings;
use Perl::Lint::Policy::ClassHierarchies::ProhibitExplicitISA;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ClassHierarchies::ProhibitExplicitISA';

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
print @Foo::ISA;
use base 'Foo';

===
--- dscr: Basic failure
--- failures: 3
--- params:
--- input
our @ISA = qw(Foo);
push @ISA, 'Foo';
@ISA = ('Foo');
