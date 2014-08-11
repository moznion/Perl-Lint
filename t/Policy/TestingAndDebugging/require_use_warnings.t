#!perl

use strict;
use warnings;
use Perl::Lint::Policy::TestingAndDebugging::RequireUseWarnings;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'TestingAndDebugging::RequireUseWarnings';

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
--- dscr: 1 statement before warnings
--- failures: 1
--- params:
--- input
$foo = $bar;
use warnings;

===
--- dscr: several statements before warnings
--- failures: 1
--- params:
--- input
$foo = $bar;   ## This one violates.
$baz = $nuts;  ## no critic;  This one is exempted
$blamo;        ## This one should be squelched
use warnings;

===
--- dscr: no warnings at all
--- failures: 1
--- params:
--- input
$foo = $bar;

===
--- dscr: no warnings at all with "use 5.005"
--- failures: 0
--- params:
--- input
use 5.005;
$foo = $bar;

===
--- dscr: no warnings at all with "use 5.006"
--- failures: 1
--- params:
--- input
use 5.006;
$foo = $bar;

===
--- dscr: require warnings
--- failures: 1
--- params:
--- input
require warnings;
1;

===
--- dscr: warnings used, but no code
--- failures: 0
--- params:
--- input
use warnings;

# TODO
# ===
# --- dscr: -w used, but no code
# --- failures: 0
# --- params:
# --- input
# #!perl -w

# TODO
# ===
# --- dscr: -W used, but no code
# --- failures: 0
# --- params:
# --- input
# !perl -W

===
--- dscr: no warnings at all, w/END
--- failures: 1
--- params:
--- input
$foo = $bar;

#Should not find the rest of these

__END__

=head1 NAME

Foo - A Foo factory class

=cut

===
--- dscr: no warnings at all, w/DATA
--- failures: 1
--- params:
--- input
$foo = $bar;

#Should not find the rest of these

__DATA__

Fred
Barney
Wilma

===
--- dscr: warnings used
--- failures: 0
--- params:
--- input
use warnings;
$foo = $bar;

===
--- dscr: Other module included before warnings
--- failures: 0
--- params:
--- input
use Module;
use warnings;
$foo = $bar;

===
--- dscr: name package statement before warnings
--- failures: 0
--- params:
--- input
package FOO;
use warnings;
$foo = $bar;

===
--- dscr: Work around a PPI bug that doesn't return a location for C<({})>.
--- failures: 1
--- params:
--- input
({})

===
--- dscr: Moose support
--- failures: 0
--- params:
--- input
use Moose;
$foo = $bar;

===
--- dscr: Moose::Role support
--- failures: 0
--- params:
--- input
use Moose::Role;
$foo = $bar;

===
--- dscr: Moose::Util::TypeConstraints support
--- failures: 0
--- params:
--- input
use Moose::Util::TypeConstraints;
$foo = $bar;

===
--- dscr: equivalent_modules
--- failures: 0
--- params: {require_use_warnings => {equivalent_modules => 'Foo'}}
--- input
use Foo;
$foo = $bar;

===
--- dscr: "use warnings" in lexical context (BEGIN block) RT #42310
--- failures: 1
--- params:
--- input

BEGIN { use warnings }  # notice this is first statement in file

===
--- dscr: "use warnings" in lexical context (subroutine) RT #42310
--- failures: 1
--- params:
--- input

sub foo { use warnings }  # notice this is first statement in file

