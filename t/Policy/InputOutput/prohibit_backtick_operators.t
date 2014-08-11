use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::ProhibitBacktickOperators;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::ProhibitBacktickOperators';

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
--- dscr: Basic failures
--- failures: 18
--- params:
--- input
$string = `date`;
@array = `date`;
@array = ( `date` );
@array = ( $foo, `date`, 'bar' );
$array_ref = [ $foo, `date`, 'bar' ];

print `date`;
print ( `date` );

if ( `date` ) {}

for ( `date` ) {}

$string = qx/date/;
@array = qx/date/;
@array = ( qx/date/ );
@array = ( $foo, qx/date/, 'bar' );
$array_ref = [ $foo, qx/date/, 'bar' ];

print qx/date/;
print ( qx/date/ );

if ( qx/date/ ) {}

for ( qx/date/ ) {}

===
--- dscr: Passing with only_in_void_context
--- failures: 0
--- params: { prohibit_backtick_operators => { only_in_void_context => 1 } }
--- input
$string = `date`;
@array = `date`;
@array = ( `date` );
@array = ( $foo, `date`, 'bar' );
$array_ref = [ $foo, `date`, 'bar' ];

print `date`;
print ( `date` );

if ( `date` ) {}
last if `date`
last if (`date`)

for ( `date` ) {}

$string = qx/date/;
@array = qx/date/;
@array = ( qx/date/ );
@array = ( $foo, qx/date/, 'bar' );
$array_ref = [ $foo, qx/date/, 'bar' ];

print qx/date/;
print ( qx/date/ );

if ( qx/date/ ) {}

for ( qx/date/ ) {}

===
--- dscr: Failure with only_in_void_context
--- failures: 6
--- params: { prohibit_backtick_operators => { only_in_void_context => 1 } }
--- input
`date`;
qx/date/;

if ( $blah ) { `date` }
if ( $blah ) { qx/date/ }
`date` if $blah
`date` if ($blah)

