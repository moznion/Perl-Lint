use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitMixedBooleanOperators;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitMixedBooleanOperators';

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
--- dscr: High-precedence passing
--- failures: 0
--- params:
--- input
next if ! $finished || $foo < $bar;
if( $foo && !$bar || $baz){ do_something() }
this() && !that() || the_other();

===
--- dscr: Low-precedence passing
--- failures: 0
--- params:
--- input
next if not $finished or $foo < $bar;
if( $foo and not $bar or $baz ){ do_something() }
this() and not that() or the_other();

===
--- dscr: Basic failure
--- failures: 3
--- params:
--- input
next if not $finished || $foo < $bar;
if( $foo && not $bar or $baz ){ do_something() }
this() and ! that() or the_other();

===
--- dscr: High-precedence with low precedence self-equals
--- failures: 0
--- params:
--- input
$sub ||= sub {
   return 1 and 2;
};

===
--- dscr: Mixed booleans in same statement, but different expressions
--- failures: 0
--- params:
--- input
# See http://rt.cpan.org/Ticket/Display.html?id=27637
ok( ! 1, 'values are URLs' ) or diag 'never happens';

===
--- dscr: Mixed booleans in code blocks
--- failures: 0
--- params:
--- input
eval {
    if (1 || 2) {
        return not 3;
    }
};

