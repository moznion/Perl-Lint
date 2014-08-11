use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::ProhibitUniversalCan;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::ProhibitUniversalCan';

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
use UNIVERSAL::can;
require UNIVERSAL::can;
$foo->can($funcname);

===
--- dscr: Basic failure
--- failures: 2
--- params:
--- input
can($foo, $funcname);
UNIVERSAL::can($foo, $funcname);

