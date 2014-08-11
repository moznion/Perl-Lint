#!perl

use strict;
use warnings;
use Perl::Lint::Policy::TestingAndDebugging::RequireTestLabels;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'TestingAndDebugging::RequireTestLabels';

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
--- dscr: standard failures
--- failures: 15
--- params: {}
--- input
use Test::More tests => 10;
ok($foo);
ok(!$foo);
is(1,2);
isnt(1,2);
like('foo',qr/f/);
unlike('foo',qr/f/);
cmp_ok(1,'==',2);
is_deeply('literal','literal');
is_deeply([], []);
is_deeply({}, {});
pass();
fail();
pass;
fail;
ok $foo;

===
--- dscr: name standard passing
--- failures: 0
--- params: {}
--- input
ok($foo);
ok(!$foo);
is(1,2);
isnt(1,2);
like('foo',qr/f/);
unlike('foo',qr/f/);
cmp_ok(1,'==',2);
is_deeply('literal','literal');
is_deeply([], []);
is_deeply({}, {});
pass();
fail();

===
--- dscr: name more passing
--- failures: 0
--- params: {}
--- input
use Test::More tests => 10;
ok($foo,'label');
ok(!$foo,'label');
is(1,2,'label');
isnt(1,2,'label');
like('foo',qr/f/,'label');
unlike('foo',qr/f/,'label');
cmp_ok(1,'==',2,'label');
is_deeply('literal','literal','label');
pass('label');
fail('label');


===
--- dscr: empty array and hash parsing
--- failures: 0
--- params: {}
--- input
is_deeply([],[],'label');
is_deeply({},{},'label');

===
--- dscr: exceptions
--- failures: 1
--- params: {require_test_labels => {modules => 'Test::Foo Test::Bar'}}
--- input
use Test::Bar tests => 10;
ok($foo);

===
--- dscr: more exceptions
--- failures: 0
--- params: {require_test_labels => {modules => 'Test::Foo Test::Bar'}}
--- input
use Test::Baz tests => 10;
ok($foo);

===
--- dscr: RT 24924, is_deeply (from Perl::Critic)
--- failures: 0
--- params: {}
--- input
use Test::More;

is_deeply( { foo => 1 }, { foo => 1 }, 'Boldly criticize where nobody has criticize before.' );

is_deeply( { get_empty_array() }, {}, 'Wrap sub-call in hash constructor' );
