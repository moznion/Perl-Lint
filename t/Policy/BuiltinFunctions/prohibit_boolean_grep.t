use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::ProhibitBooleanGrep;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::ProhibitBooleanGrep';

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
print grep("$foo", @list);
print ( grep "$foo", @list );
@list = ( grep "$foo", @list );
$aref = [ grep "$foo", @list ];
$href = { grep "$foo", @list };

===
--- dscr: Counting is allowed
--- failures: 0
--- params:
--- input
$count = grep {m/./xms} @list

===
--- dscr: Non-boolean in conditional
--- failures: 0
--- params:
--- input
if (0 == grep {m/./xms} @list) {}

===
--- dscr: For loop is not conditional
--- failures: 0
--- params:
--- input
for( grep { foo($_) } @list ) {}
foreach( grep { foo($_) } @list ) {}

===
--- dscr: Control structures
--- failures: 4
--- params:
--- input
if( grep { foo($_) } @list ) {}
unless( grep { foo($_) } @list ) {}
while( grep { foo($_) } @list ) {}
until( grep { foo($_) } @list ) {}

===
--- dscr: Postfix control structures
--- failures: 4
--- params:
--- input
foo() if grep { bar($_) } @list;
foo() unless grep { bar($_) } @list;
foo() while grep { bar($_) } @list;
foo() until grep { bar($_) } @list;

===
--- dscr: Complex booleans
--- failures: 1
--- params:
--- input
if( 1 && grep { foo($_) } @list ) {}

===
--- dscr: Complex booleans
--- failures: 1
--- params:
--- input

$bar = grep({foo()} @list) && 1;

===
--- dscr: Complex booleans
--- failures: 0
--- params:
--- input
1 && grep({foo()} @list) == 0;

===
--- dscr: Complex booleans
--- failures: 1
--- params:
--- input
1 && grep({foo()} @list) && 0;

===
--- dscr: Complex booleans
--- failures: 1
--- params:
--- input
## TODO detect end of statement
1 && grep({foo()} @list);

===
--- dscr: Complex booleans
--- failures: 1
--- params:
--- input
(1 && grep({foo()} @list));

===
--- dscr: code coverage...
--- failures: 1
--- params:
--- input
(1 && grep);

===
--- dscr: code coverage...
--- failures: 0
--- params:
--- input
$hash->{grep};

