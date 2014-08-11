use strict;
use warnings;
use Perl::Lint::Policy::CodeLayout::ProhibitParensWithBuiltins;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'CodeLayout::ProhibitParensWithBuiltins';

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
open ($foo, $bar);
open($foo, $bar);
uc();
lc();

# These ones deliberately omit the semi-colon
sub {uc()}
sub {reverse()}

===
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
open $foo, $bar;
uc $foo;
lc $foo;
my $foo;
my ($foo, $bar);
our ($foo, $bar);
local ($foo $bar);
return ($foo, $bar);
return ();
my_subroutine($foo $bar);
{print}; # for Devel::Cover

===
--- dscr: Method invocation
--- failures: 0
--- params:
--- input
my $obj = SomeClass->new();
$obj->open();
$obj->close();
$obj->prototype();
$obj->delete();

is( pcritique($policy, \$code), 0, $policy);

===
--- dscr: Unary operators with parens, followed by a high-precedence operator
--- failures: 0
--- params:
--- input
$foo = int( 0.5 ) + 1.5;
$foo = int( 0.5 ) - 1.5;
$foo = int( 0.5 ) * 1.5;
$foo = int( 0.5 ) / 1.5;
$foo = int( 0.5 ) ** 1.5;

$foo = oct( $foo ) + 1;
$foo = ord( $foo ) - 1;
$foo = sin( $foo ) * 2;
$foo = uc( $foo ) . $bar;
$foo = lc( $foo ) . $bar;

$nanosecond = int ( ($value - $epoch) * $NANOSECONDS_PER_SECOND );

===
--- dscr: RT #21713
--- failures: 0
--- params:
--- input
print substr($foo, 2, 3), "\n";
if ( unpack('V', $foo) == 2 ) { }

===
--- dscr: Parentheses with greedy functions
--- failures: 0
--- params:
--- input
substr join( $delim, @list), $offset, $length;
print reverse( $foo, $bar, $baz), $nuts;
sort map( {some_func($_)} @list1 ), @list2;

===
--- dscr: Test cases from RT
--- failures: 0
--- params:
--- input
chomp( my $foo = <STDIN> );
defined( my $child = shift @free_children )
return ( $start_time + $elapsed_hours ) % $hours_in_day;

===
--- dscr: High-precedence operator after parentheses
--- failures: 0
--- params:
--- input
grep( { do_something($_) }, @list ) + 3;
join( $delim, @list ) . "\n";
pack( $template, $foo, $bar ) . $suffix;
chown( $file1, $file2 ) || die q{Couldn't chown};

===
--- dscr: Low-precedence operator after parentheses
--- failures: 2
--- params:
--- input
grep( { do_something($_) }, $foo, $bar) and do_something();
chown( $file1, $file2 ) or die q{Couldn't chown};

===
--- dscr: Named unary op with operator inside parenthesis (RT #46862)
--- failures: 0
--- params:
--- input
length( $foo // $bar );
stat( $foo || $bar );
uc( $this & $that );

===
--- dscr: Handling sort having subroutine name as an argument
--- failures: 0
--- params:
--- input
sort(foo(@x));
[ sort ( modules_used_in_string( $code ) ) ]

===
--- dscr: RT 52029 - Accept parens with 'state'
--- failures: 0
--- params:
--- input
use 5.010;

state ( $foo );

