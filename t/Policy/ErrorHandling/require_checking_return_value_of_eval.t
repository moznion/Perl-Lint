#!perl

use strict;
use warnings;
use Perl::Lint::Policy::ErrorHandling::RequireCheckingReturnValueOfEval;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ErrorHandling::RequireCheckingReturnValueOfEval';

for my $block (blocks) {
    my $violations = fetch_violations($class_name, $block->input);
    is scalar @$violations, $block->failures, $block->dscr;
}

done_testing;

__DATA__

===
--- dscr: Basic Failure
--- failures: 9
--- input
eval { foo; };
{ eval { baz; } };
[ eval { buz; } ];
( eval { blrfl; } );

eval 'foo;';
{ eval 'baz;' };
[ eval 'buz;' ];
( eval 'blrfl;' );

eval { something };
if ($@) {
    blahblah
}

===
--- dscr: Assignment
--- failures: 0
--- input
$result = eval { foo; };
@result = eval { bar; };
$result = { eval { baz; } };
$result = [ eval { buz; } ];
@result = ( 0, eval { blrfl; } );
@result = [ qw< one two >, { thrpt => ( eval { frlbfrnk; } ) } ];

$result = eval 'foo;';
@result = eval 'bar;';
$result = { eval 'baz;' };
$result = [ eval 'buz;' ];
@result = ( 0, eval 'blrfl;' );
@result = [ qw< one two >, { thrpt => ( eval 'frlbfrnk;' ) } ];

===
--- dscr: Assignment with comma separated statements.
--- failures: 12
--- input
$result = 1, eval { foo; };
@result = 1, eval { bar; };
$result = 1, { eval { baz; } };
$result = 1, [ eval { buz; } ];
@result = 1, ( eval { blrfl; } );
@result = 1, [ qw< one two >, { thrpt => ( eval { frlbfrnk; } ) } ];

$result = 1, eval 'foo;';
@result = 1, eval 'bar;';
$result = 1, { eval 'baz;' };
$result = 1, [ eval 'buz;' ];
@result = 1, ( eval 'blrfl;' );
@result = 1, [ qw< one two >, { thrpt => ( eval 'frlbfrnk;' ) } ];

===
--- dscr: if
--- failures: 0
--- input
if ( eval { bar; } ) {
    something
}
if ( ( eval { blrfl; } ) ) {
    something
}
if ( 5 == eval { bar; } ) {
    something
}
if ( scalar ( eval { blrfl; } ) ) {
    something
}
if ( not eval { whatever; } ) {
    something
}
if ( eval 'bar;' ) {
    something
}
if ( ( eval 'blrfl;' ) ) {
    something
}
if ( 5 == eval 'bar;' ) {
    something
}
if ( scalar ( eval 'blrfl;' ) ) {
    something
}
if ( ! eval 'whatever;' ) {
    something
}

===
--- dscr: foreach
--- failures: 0
--- input
foreach my $thingy ( eval { bar; } ) {
    something
}
foreach my $thingy ( ( eval { blrfl; } ) ) {
    something
}
foreach my $thingy ( qw< one two >, eval { bar; } ) {
    something
}
foreach my $thingy ( eval 'bar;' ) {
    something
}
foreach my $thingy ( ( eval 'blrfl;' ) ) {
    something
}
foreach my $thingy ( qw< one two >, eval 'bar;' ) {
    something
}

===
--- dscr: C-style for with eval in condition or assignment
--- failures: 0
--- input
for (blah; eval { bar; }; blah ) {
    something
}
for (blah; ( eval { blrfl; } ); blah ) {
    something
}
for (blah; eval { bar; } eq 'bing bang bong'; blah ) {
    something
}
for (my $x = eval { thrp; }; $x < 1587; $x = eval { thrp; } ) {
    something
}
for (blah; eval 'bar;'; blah ) {
    something
}
for (blah; ( eval 'blrfl;' ); blah ) {
    something
}
for (blah; eval 'bar;' eq 'bing bang bong'; blah ) {
    something
}
for (my $x = eval 'thrp;'; $x < 1587; $x = eval 'thrp;' ) {
    something
}

===
--- dscr: C-style for with eval in initialization or increment with no assignment
--- failures: 4
--- input
for (eval { bar; }; blah; blah) {
    something
}
for ( blah; blah; ( eval { blrfl; } ) ) {
    something
}
for (eval 'bar;'; blah; blah) {
    something
}
for ( blah; blah; ( eval 'blrfl;' ) ) {
    something
}

===
--- dscr: while
--- failures: 0
--- input
while ( eval { bar; } ) {
    something
}
while ( ( ( eval { blrfl; } ) ) ) {
    something
}
while ( eval 'bar;' ) {
    something
}
while ( ( ( eval 'blrfl;' ) ) ) {
    something
}

===
--- dscr: Postfix if
--- failures: 0
--- input
bleah if eval { yadda; };
bleah if ( eval { yadda; } );
bleah if 5 == eval { yadda; };
bleah if eval { yadda; } == 5;

bleah if eval 'yadda;';
bleah if ( eval 'yadda;' );
bleah if 5 == eval 'yadda;';
bleah if eval 'yadda;' == 5;

===
--- dscr: Ternary
--- failures: 0
--- input
eval { yadda; } ? 1 : 2;
eval 'yadda;' ? 1 : 2;

===
--- dscr: Postfix foreach
--- failures: 0
--- input
blargh($_) foreach eval { bar; };
blargh($_) foreach ( eval { blrfl; } );
blargh($_) foreach qw< one two >, eval { bar; };
blargh($_) foreach eval { bar; }, qw< one two >;

blargh($_) foreach eval 'bar;';
blargh($_) foreach ( eval 'blrfl;' );
blargh($_) foreach eval 'bar;', qw< one two >;

===
--- dscr: First value in comma-separated list in condition
--- failures: 4
--- input
if ( eval { 1 }, 0 ) {
    blah blah blah
}

if ( ( eval { 1 }, 0 ) ) {
    blah blah blah
}

if ( eval '1', 0 ) {
    blah blah blah
}

if ( ( eval '1', 0 ) ) {
    blah blah blah
}

===
--- dscr: Last value in comma-separated list in condition
--- failures: 0
--- input
if ( 0, eval { 1 }, ) {
    blah blah blah
}
# Comma outside inner parentheses.
if ( ( 0, eval { 1 } ), , ) {
    blah blah blah
}
if ( 0, eval '1', ) {
    blah blah blah
}
# Comma inside inner parentheses.
if ( ( 0, eval '1', , ) ) {
    blah blah blah
}

===
--- dscr: Last value in comma-separated list that isn't the last element in another list in condition
--- failures: 4
--- input
if ( ( 0, eval { 1 } ), 0 ) {
    blah blah blah
}
if ( ( ( 0, eval { 1 } ) ), 0 ) {
    blah blah blah
}
if ( ( 0, eval '1' ), 0 ) {
    blah blah blah
}
if ( ( ( 0, eval '1' ) ), 0 ) {
    blah blah blah
}

===
--- dscr: "Proper" handling of return value
--- failures: 0
--- input
eval {
    something
}
    or do {
        if ($EVAL_ERROR) {
            yadda
        }
        else {
            blahdda
        };

eval "something_else" or die;

# eval gets the thing following it before || does.
eval {
    something
}
    || do {
        if ($EVAL_ERROR) {
            yadda
        }
        else {
            blahdda
        }
    };

eval "something_else" || die;


eval {
    something
}
    and do {
        yadda
    };

eval "something_else" and thingy;

# eval gets the thing following it before && does.
eval {
    something
}
    && do {
        yadda
    };

eval "something_else" && die;

===
--- dscr: A grep is a check -- RT #69489
--- failures: 0
--- input
foreach ( grep { eval $_ } @bar ) { say }
foreach ( grep { ! eval $_ } @bar ) { say }
foreach ( grep eval $_, @bar ) { say }
foreach ( grep ! eval $_, @bar ) { say }

# grep $_, map eval $_, @foo;   # Should this be accepted?
grep { $_ } map { eval $_ } @foo;   # Should this be rejected?
