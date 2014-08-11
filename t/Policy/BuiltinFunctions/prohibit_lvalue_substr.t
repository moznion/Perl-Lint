use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::ProhibitLvalueSubstr;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::ProhibitLvalueSubstr';

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
--- dscr: lvalue
--- failures: 1
--- params:
--- input
substr( $foo, 2, 1 ) = 'XYZ';

===
--- dscr: 4 arg substr
--- failures: 0
--- params:
--- input
substr $foo, 2, 1, 'XYZ';

===
--- dscr: rvalue
--- failures: 0
--- params:
--- input
$bar = substr( $foo, 2, 1 );

===
--- dscr: hash rvalue
--- failures: 0
--- params:
--- input
%bar = ( foobar => substr( $foo, 2, 1 ) );

===
--- dscr: substr as word
--- failures: 0
--- params:
--- input
$foo{substr};

===
--- dscr: low precedence boolean blocks assignment
--- failures: 0
--- params:
--- input
'x' eq substr $foo, 0, 1 or $foo = 'x' . $foo;

===
--- dscr: allow under really old Perl. RT #59112
--- failures: 0
--- params:
--- input
use 5.004;

substr( $foo, 0, 0 ) = 'bar';

