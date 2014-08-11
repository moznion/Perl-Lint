#!perl

use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::ProhibitVoidMap;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::ProhibitVoidMap';

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
--- failures: 8
--- params:
--- input
map "$foo", @list;
map("$foo", @list);
map { foo($_) } @list;
map({ foo($_) } @list);

if( $condition ){ map { foo($_) } @list }
unless( $condition ){ map { foo($_) } @list }
while( $condition ){ map { foo($_) } @list }
for( @list ){ map { foo($_) } @list }

===
--- dscr: Chained void map
--- failures: 1
--- params:
--- input
map { foo($_) }
  map { bar($_) }
    map { baz($_) } @list;

===
--- dscr: not builtin map
--- failures: 0
--- params:
--- input
$self->map('Pennsylvania Ave, Washington, DC');

===
--- dscr: Subscript map (derived from Perl::Critic RT #79289)
--- failures: 0
--- params:
--- input
my %hash;

delete @hash{ map { uc $_ } keys %hash };
delete @hash{ map uc( $_ ), keys %hash };
# This is the form analogous to what failed under RT #79289.
delete @hash{ map ( uc( $_ ), keys %hash ) };

