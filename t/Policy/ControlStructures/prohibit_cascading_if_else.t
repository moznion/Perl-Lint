use strict;
use warnings;
use Perl::Lint::Policy::ControlStructures::ProhibitCascadingIfElse;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ControlStructures::ProhibitCascadingIfElse';

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
if ($condition1){
  $foo;
}
elsif ($condition2){
  $bar;
}
elsif ($condition3){
  $bar;
}
else {
  $nuts;
}

if ($condition1){
  $foo;
}
else {
  $nuts;
}

if ($condition1){
  $foo;
}

foreach (1,2,3){
 $foo;
}

===
--- dscr: Basic failure
--- failures: 1
--- params:
--- input
if ($condition1){
  $foo;
}
elsif ($condition2){
  $bar;
}
elsif ($condition3){
  $baz;
}
elsif ($condition4){
  $barf;
}
else {
  $nuts;
}

===
--- dscr: With custom max_elsif value.
--- failures: 1
--- params: {prohibit_cascading_if_else => {max_elsif => 1}}
--- input
if ($condition1){
  $foo;
}
elsif ($condition2){
  $bar;
}
elsif ($condition3){
  $baz;
}
else {
  $nuts;
}

