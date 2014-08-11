use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::ProhibitComplexMappings;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::ProhibitComplexMappings';

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
map {$_} @list;
map {substr $_, 0, 10;} @list;
map {foo($_)} @list;
map {{$_ => 1}} @list;

map $_, @list;
map substr($_, 0, 10), @list;
map foo($_), @list;
map {$_ => 1}, @list;

$foo{map}; # for Devel::Cover
{map}; # for Devel::Cover
map();

===
--- dscr: Basic failure
--- failures: 2
--- params:
--- input
map {my $a = $foo{$_};$a} @list;
map {if ($_) { 1 } else { 2 }} @list;

===
--- dscr: Compound statements (false negative)
--- failures: 0
--- params:
--- input
map {do {$a; $b}} @list;
map do {$a; $b}, @list;

===
--- dscr: Vary config parameters: success
--- failures: 0
--- params: {prohibit_complex_mappings => {max_statements => 2}}
--- input
map {my $a = $foo{$_};$a} @list;

===
--- dscr: Vary config parameters: failue
--- failures: 1
--- params: {prohibit_complex_mappings => {max_statements => 2}}
--- input
map {my $a = $foo{$_};$a;$b} @list;

