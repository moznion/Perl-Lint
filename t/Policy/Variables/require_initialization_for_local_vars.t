use strict;
use warnings;
use Perl::Lint::Policy::Variables::RequireInitializationForLocalVars;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Variables::RequireInitializationForLocalVars';

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
--- dscr: Basic
--- failures: 6
--- params:
--- input
local $foo;
local ($foo, $bar);

local $|;
local ($|, $$);

local $OUTPUT_RECORD_SEPARATOR;
local ($OUTPUT_RECORD_SEPARATOR, $PROGRAM_NAME);

===
--- dscr: Initialized passes
--- failures: 0
--- params:
--- input
local $foo = 'foo';
local ($foo, $bar) = 'foo';       #Not right, but still passes
local ($foo, $bar) = qw(foo bar);

my $foo;
my ($foo, $bar);
our $bar
our ($foo, $bar);

===
--- dscr: key named "local"
--- failures: 0
--- params:
--- input
$x->{local};

