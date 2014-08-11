#!perl

use strict;
use warnings;
use Perl::Lint::Policy::TestingAndDebugging::ProhibitNoWarnings;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'TestingAndDebugging::ProhibitNoWarnings';

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
--- dscr: warnings disabled
--- failures: 1
--- params:
--- input
package foo;

no warnings;

===
--- dscr: selective warnings disabled, regular quotes
--- failures: 1
--- params:
--- input
package foo;

no warnings 'uninitialized', 'deprecated';

===
--- dscr: selective warnings disabled, qw<>
--- failures: 1
--- params:
--- input
package foo;

no warnings qw(closure glob);

===
--- dscr: allow no warnings, mixed case config
--- failures: 0
--- params: {prohibit_no_warnings => {allow => 'iO Glob OnCe'}}
--- input
package foo;

no warnings qw(glob io once);

===
--- dscr: allow no warnings, comma delimimted
--- failures: 0
--- params: {prohibit_no_warnings => {allow => 'numeric,portable, pack'}}
--- input
package foo;

no warnings "numeric", "pack", "portable";

===
--- dscr: wrong case, funky config
--- failures: 1
--- params: {prohibit_no_warnings => {allow => 'NumerIC;PORTABLE'}}
--- input
package foo;

no warnings "numeric", "pack", 'portable';

===
--- dscr: More wrong case, funky config
--- failures: 1
--- params: {prohibit_no_warnings => {allow => 'paCK/PortablE'}}
--- input
package foo;

no warnings qw(numeric pack portable);

===
--- dscr: with_at_least_one, no categories
--- failures: 1
--- params: {prohibit_no_warnings => {allow_with_category_restriction => 1}}
--- input
package foo;

no warnings;

===
--- dscr: with_at_least_one, one category
--- failures: 0
--- params: {prohibit_no_warnings => {allow_with_category_restriction => 1}}
--- input
package foo;

no warnings "uninitalized";

===
--- dscr: with_at_least_one, many categories, regular quotes
--- failures: 0
--- params: {prohibit_no_warnings => {allow_with_category_restriction => 1}}
--- input
package foo;

no warnings "uninitialized", 'glob';

===
--- dscr: with_at_least_one, many categories, qw<>
--- failures: 0
--- params: {prohibit_no_warnings => {allow_with_category_restriction => 1}}
--- input
package foo;

no warnings qw< uninitialized glob >;

===
--- dscr: allow_with_category_restriction, category qw. RT #74647,
--- failures: 0
--- params: {prohibit_no_warnings => {allow_with_category_restriction => 1}}
--- input
no warnings 'qw';   # Yes, 'qw' is an actual warnings category.
no warnings ( foo => "bar" );

