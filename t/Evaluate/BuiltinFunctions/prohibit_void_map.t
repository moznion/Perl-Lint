#!perl

use strict;
use warnings;
use Perl::Lint::Evaluator::BuiltinFunctions::ProhibitVoidMap;
use t::Evaluate::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::ProhibitVoidMap';

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
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
$baz, map "$foo", @list;
print map("$foo", @list);
print ( map "$foo", @list );
@list = ( map $foo, @list );
$aref = [ map $foo, @list ];
$href = { map $foo, @list };

if( map { foo($_) } @list ) {}
for( map { foo($_) } @list ) {}

===
--- dscr: Basic failure
--- failures: 7
--- params:
--- input
map "$foo", @list;
map("$foo", @list);
map { foo($_) } @list;
map({ foo($_) } @list);

if( $condition ){ map { foo($_) } @list }
while( $condition ){ map { foo($_) } @list }
for( @list ){ map { foo($_) } @list }
