#!perl

use strict;
use warnings;
use Perl::Lint::Policy::Subroutines::ProhibitBuiltinHomonyms;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Subroutines::ProhibitBuiltinHomonyms';

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
--- dscr: Basic failures
--- failures: 7
--- params:
--- input
sub open {}
sub map {}
sub eval {}
sub if {}
sub sub {}
sub foreach {}
sub while {}

===
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
sub my_open {}
sub my_map {}
sub eval2 {}

===
--- dscr: Acceptable homonyms
--- failures: 0
--- params:
--- input
sub import   { do_something(); }
sub AUTOLOAD { do_something(); }
sub DESTROY  { do_something(); }
BEGIN { do_something(); }
INIT  { do_something(); }
CHECK { do_something(); }
END   { do_something(); }

