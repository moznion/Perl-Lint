use strict;
use warnings;
use Perl::Lint::Policy::ControlStructures::ProhibitUnlessBlocks;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ControlStructures::ProhibitUnlessBlocks';

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
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
if(! $condition){
  do_something();
}

do_something() unless $condition

===
--- dscr: Basic failure
--- failures: 1
--- params:
--- input
unless($condition){
  do_something();
}

