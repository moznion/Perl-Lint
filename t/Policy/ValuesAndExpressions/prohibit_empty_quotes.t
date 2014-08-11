#!perl

use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitEmptyQuotes;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitEmptyQuotes';

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
--- dscr: Basic failure
--- failures: 4
--- params:
--- input
$var = "";
$var = ''
$var = '     ';
$var = "     ";

===
--- dscr: Quote-like operator passing
--- failures: 0
--- params:
--- input
$var = qq{};
$var = q{}
$var = qq{     };
$var = q{     };

===
--- dscr: Non-empty passing
--- failures: 0
--- params:
--- input
$var = qq{this};
$var = q{that}
$var = qq{the};
$var = q{other};
$var = "this";
$var = 'that';
$var = 'the';
$var = "other";
