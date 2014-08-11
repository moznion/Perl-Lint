#!perl

use strict;
use warnings;
use Perl::Lint::Policy::Subroutines::ProhibitUnusedPrivateSubroutines;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Subroutines::ProhibitUnusedPrivateSubroutines';

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
--- dscr: basic failure
--- failures: 1
--- params:
--- input
sub _foo {};

===
--- dscr: basic pass
--- failures: 0
--- params:
--- input
sub _foo {};
_foo;

===
--- dscr: Method call is OK
--- failures: 0
--- params:
--- input
sub _foo {};
$self->_foo();

===
--- dscr: Method call where invocant is "shift"
--- failures: 0
--- params:
--- input
sub _foo {};
shift->_foo;

===
--- dscr: other builtin-function followed by private method call
--- failures: 0
--- params:
--- input
sub _foo {};
pop->_foo();

===
--- dscr: Maybe non-obvious failure
--- failures: 1
--- params:
--- input
sub _foo {};

$self->SUPER::_foo();

===
--- dscr: Forward references do not count
--- failures: 0
--- params:
--- input
sub _foo;

===
--- dscr: User-configured exceptions.
--- failures: 0
--- params: {prohibit_unused_private_subroutines => {allow => '_foo _bar _baz'}}
--- input
sub _foo {};
sub _bar ($) {};
sub _baz : method {};

===
--- dscr: private_name_regex passing
--- failures: 0
--- params: {prohibit_unused_private_subroutines => {private_name_regex => '_(?:_|parse_)\w+'}}
--- input
sub __foo {};
sub __bar ($) {};
sub __baz : method {};
sub _parse_my_argument {};

===
--- dscr: private_name_regex failure
--- failures: 3
--- params: {prohibit_unused_private_subroutines => {private_name_regex => '_(?:_)\w+'}}
--- input
sub _foo {};
sub _bar ($) {};
sub _baz : method {};

===
--- dscr: reference to private subroutine
--- failures: 0
--- params:
--- input
sub _foo {};
my $bar = \&_foo;

===
--- dscr: goto to private subroutine
--- failures: 0
--- params:
--- input
sub _foo {};
sub bar {
    goto &_foo;
}

===
--- dscr: private subroutine used in overload
--- failures: 0
--- params:
--- input
use overload ( cmp => '_compare' );
sub _compare {};

===
--- dscr: private subroutine used in overload, the bad way
--- failures: 0
--- params:
--- input
use overload ( cmp => _compare => foo => 'bar' );
sub _compare {};

===
--- dscr: private subroutine used in overload, by reference
--- failures: 0
--- params:
--- input
use overload ( cmp => \&_compare );
sub _compare {};

===
--- dscr: recursive but otherwise unused subroutine
--- failures: 2
--- params:
--- input
sub _foo {
    my ( $arg ) = @_;
    return $arg <= 1 ? $arg : $arg * _foo( $arg - 1 );
}

sub _bar {
    --$_[0] > 0 and goto &_bar;
    return $_[0];
}

===
--- dscr: recursive subroutine called outside itself
--- failures: 0
--- params:
--- input
_foo( 3 );
sub _foo {
    my ( $arg ) = @_;
    return $arg <= 1 ? $arg : $arg * _foo( $arg - 1 );
}

_bar( 1.3 );
sub _bar {
    --$_[0] > 0 and goto &_bar;
    return $_[0];
}

===
--- dscr: subroutine declared in someone else's name space
--- failures: 0
--- params:
--- input
sub _Foo::_foo {}

===
--- dscr: Subroutine called in replacement portion of s/.../.../e
--- failures: 0
--- params:
--- input
s/ ( foo ) / _bar( $1 ) /smxe;

sub _bar {
    my ( $foo ) = @_;
    return $foo x 3;
}

===
--- dscr: Subroutine called in regexp interpolation
--- failures: 0
--- params:
--- input
s/ ( foo ) /@{[ _bar( $1 ) ]}/smx;

sub _bar {
    my ( $foo ) = @_;
    return $foo x 3;
}

===
--- dscr: Subroutine called in regexp embedded code
--- failures: 0
--- params:
--- input
m/ (?{ _foo() }) /smx;

sub _foo {
    return 'bar';
}

===
--- dscr: RT 61311: dies on "&_name" call
--- failures: 0
--- params:
--- input
sub first {
    &_second();
}

sub _second {
    print "A private sub\n";
}
