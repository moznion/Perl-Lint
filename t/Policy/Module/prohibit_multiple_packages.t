use strict;
use warnings;
use Perl::Lint::Policy::Modules::ProhibitMultiplePackages;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Modules::ProhibitMultiplePackages';

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
--- dscr: basic pass, no package
--- failures: 0
--- params:
--- input
#no package
$some_code = $foo;

===
--- dscr: basic failure
--- failures: 2
--- params:
--- input
package foo;
package bar;
package nuts;
$some_code = undef;

===
--- dscr: basic pass, with code
--- failures: 0
--- params:
--- input
package foo;
$some_code = undef;

