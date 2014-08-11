use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::ProhibitInteractiveTest;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::ProhibitInteractiveTest';

filters {
    params => [qw/eval/],
};

for my $block (blocks) {
    my $violations = fetch_violations($class_name, $block->input, $block->params);
    is scalar @$violations, $block->failures, $block->dscr;
}

done_testing;

__DATA__

===
--- dscr: basic failures
--- failures: 2
--- params:
--- input
-t;
if (-t) { }

===
--- dscr: basic passes
--- failures: 0
--- params:
--- input
-toomany;
-f _;
