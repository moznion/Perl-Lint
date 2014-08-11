#!perl

use strict;
use warnings;
use Perl::Lint::Policy::Subroutines::ProhibitAmpersandSigils;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Subroutines::ProhibitAmpersandSigils';

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
--- dscr: basic failures
--- failures: 7
--- params:
--- input
&function_call();
&my_package::function_call();
&function_call( $args );
&my_package::function_call( %args );
&function_call( &other_call( @foo ), @bar );
&::function_call();

===
--- dscr: basic passing
--- failures: 0
--- params:
--- input
defined &function_call;
\ &function_call;
\&function_call;
exists &my_package::function_call;
defined &my_package::function_call;
\ &my_package::function_call;
\&my_package::function_call;
$$foo; # for Devel::Cover; skip non-backslash casts

===
--- dscr: RT #38855 passing with parens
--- failures: 0
--- params:
--- input
defined( &function_call );
exists( &function_call );

===
--- dscr: RT #49609 recognize reference-taking distributes over parens
--- failures: 0
--- params:
--- input
\( &function_call );
\( &function_call, &another_function );

===
--- dscr: more passing
--- failures: 0
--- params:
--- input
my_package::function_call();
function_call( $args );
my_package::function_call( %args );
function_call( other_call( @foo ), @bar );
\&my_package::function_call;
\&function_call;
goto &foo;

===
--- dscr: handle that the first bareword after "sort" is the comparator function
--- failures: 0
--- params:
--- input
sort &foo($x)
