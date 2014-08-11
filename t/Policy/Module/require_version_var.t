use strict;
use warnings;
use Perl::Lint::Policy::Modules::RequireVersionVar;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Modules::RequireVersionVar';

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
--- dscr: No code
--- failures: 1
--- params:
--- input
#Nothing!

===
--- dscr: basic pass
--- failures: 0
--- params:
--- input
our $VERSION = 1.0;

===
--- dscr: basic pass #2
--- failures: 0
--- params:
--- input
our ($VERSION) = 1.0;

===
--- dscr: basic pass #3
--- failures: 0
--- params:
--- input
$Package::VERSION = 1.0;

===
--- dscr: basic pass #4
--- failures: 0
--- params:
--- input
use vars '$VERSION';

===
--- dscr: basic pass #5
--- failures: 0
--- params:
--- input
use vars qw($VERSION);

===
--- dscr: fail with lexical
--- failures: 1
--- params:
--- input
my $VERSION;

===
--- dscr: fail with wrong variable
--- failures: 1
--- params:
--- input
our $Version;

===
--- dscr: Readonly VERSION
--- failures: 0
--- params:
--- input
Readonly our $VERSION = 1.0;

===
--- dscr: Readonly::Scalar VERSION
--- failures: 0
--- params:
--- input
Readonly::Scalar our $VERSION = 1.0;

===
--- dscr: Readonly::Scalar VERSION
--- failures: 1
--- params:
--- input
Readonly::Scalar my $VERSION = 1.0;  #Note this is lexical

===
--- dscr: Version as argument to package. RT #67159
--- failures: 0
--- params:
--- input
package Foo 0.001;

===
--- dscr: Package without version should still be violation. RT #67159
--- failures: 1
--- params:
--- input
package Foo;

# ===
# --- dscr: pass with "no critic" on
# --- failures: 0
# --- params:
# --- input
# #!anything              ## no critic (RequireVersionVar)

