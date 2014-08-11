#!perl

use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::ProhibitVoidGrep;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::ProhibitVoidGrep';

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

if( grep { foo($_) } @list ) {}
for( grep { foo($_) } @list ) {}

===
--- dscr: Basic failure
--- failures: 7
--- params:
--- input
grep "$foo", @list;
grep("$foo", @list);
grep { foo($_) } @list;
grep({ foo($_) } @list);

if( $condition ){ grep { foo($_) } @list }
while( $condition ){ grep { foo($_) } @list }
for( @list ){ grep { foo($_) } @list }

===
--- dscr: Comma operator
--- failures: 1
--- params:
--- input
## TODO not handled properly
$baz, grep "$foo", @list;

===
--- dscr: Chained void grep
--- failures: 1
--- params:
--- input
grep { spam($_) }
  grep { foo($_) }
    grep { bar($_) }
      grep { baz($_) } @list;

===
--- dscr: grep (RT #79289)
--- failures: 0
--- params:
--- input
my %hash;

delete @hash{ grep { m/ foo /smx } keys %hash };
delete @hash{ grep m/ foo /smx, keys %hash };
# The following is the form that was actually failing.
delete @hash{ grep ( m/ foo /smx, keys %hash ) };

