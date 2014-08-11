use strict;
use warnings;
use Perl::Lint::Policy::Variables::ProhibitLocalVars;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Variables::ProhibitLocalVars';

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
--- dscr: basics
--- failures: 3
--- params:
--- input
local $foo = $bar;
local ($foo, $bar) = ();
local ($foo, %SIG);

===
--- dscr: exceptions
--- failures: 0
--- params:
--- input
local $/ = undef;
local $| = 1;
local ($/) = undef;
local ($RS, $>) = ();
local ($RS);
local $INPUT_RECORD_SEPARATOR;
local $PROGRAM_NAME;
local ($EVAL_ERROR, $OS_ERROR);
local $Other::Package::foo;
local (@Other::Package::foo, $EVAL_ERROR);
my  $var1 = 'foo';
our $var2 = 'bar';
local $SIG{HUP} \&handler;
local $INC{$module} = $path;

