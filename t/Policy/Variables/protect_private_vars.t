use strict;
use warnings;
use Perl::Lint::Policy::Variables::ProtectPrivateVars;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Variables::ProtectPrivateVars';

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
--- failures: 6
--- params:
--- input
$Other::Package::_foo;
@Other::Package::_bar;
%Other::Package::_baz;
&Other::Package::_quux;
*Other::Package::_xyzzy;
\$Other::Package::_foo;

===
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
$_foo;
@_bar;
%_baz;
&_quux;
\$_foo;
$::_foo;

