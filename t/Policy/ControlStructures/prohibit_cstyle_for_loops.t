use strict;
use warnings;
use Perl::Lint::Policy::ControlStructures::ProhibitCStyleForLoops;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ControlStructures::ProhibitCStyleForLoops';

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
for(@list){
  do_something();
}

for my $element (@list){
  do_something();
}

foreach my $element (@list){
  do_something();
}

do_something() for @list;

===
--- dscr: Basic failure
--- failures: 1
--- params:
--- input
for($i=0; $i<=$max; $i++){
  do_something();
}

