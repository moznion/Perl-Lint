#!perl

use strict;
use warnings;
use Perl::Lint::Evaluator::TestingAndDebugging::RequireTestLabels;
use t::Evaluate::Util qw/fetch_violations/;
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
--- failures: 12
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
