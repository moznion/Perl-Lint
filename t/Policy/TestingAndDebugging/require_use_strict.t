#!perl

use strict;
use warnings;
use Perl::Lint::Policy::TestingAndDebugging::RequireUseStrict;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'TestingAndDebugging::RequireUseStrict';

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
--- dscr: one statement before strict
--- failures: 1
--- params:
--- input
$foo = $bar;
use strict;

===
--- dscr: several statements before strict
--- failures: 1
--- params:
--- input
$foo = $bar;   ## This one violates.
$baz = $nuts;  ## no critic;  This one is exempted
$blamo;        ## This one should be squelched
use strict;

===
--- dscr: no strict at all
--- failures: 1
--- params:
--- input
$foo = $bar;

===
--- dscr: name require strict
--- failures: 1
--- params:
--- input
require strict;
1;

===
--- dscr: strictures used, but no code
--- failures: 0
--- params:
--- input
use strict;

===
--- dscr: no strict at all, w/END
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
--- dscr: no strict at all, w/DATA
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
--- dscr: strictures used OK
--- failures: 0
--- params:
--- input
use strict;
$foo = $bar;

===
--- dscr: other module included before strict
--- failures: 0
--- params:
--- input
use Module;
use strict;
$foo = $bar;

===
--- dscr: package statement before strict
--- failures: 0
--- params:
--- input
package FOO;
use strict;
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
--- params: {require_use_strict => {equivalent_modules => 'Foo'}}
--- input
use Foo;
$foo = $bar;

===
--- dscr: "use strict" in lexical context (BEGIN block) RT #42310
--- failures: 1
--- params:
--- input
BEGIN{ use strict }  # notice this is first statement in file
$this_is_not_strict

===
--- dscr: "use strict" in lexical context (subroutine) RT #42310
--- failures: 1
--- params:
--- input
sub foo { use strict }  # notice this is first statement in file
$this_is_not_strict

===
--- dscr: "use perl-version" equivalent to strict as of 5.011
--- failures: 0
--- params:
--- input
use 5.011;
$foo = $bar;

===
--- dscr: "use perl-version" equivalent to strict as of 5.11.0
--- failures: 0
--- params:
--- input
use 5.11.0;
$foo = $bar;

--- dscr: "use perl-version" in lexical context
--- failures: 1
--- params:
--- input
sub foo { use 5.011 };
$this_is_not_strict
