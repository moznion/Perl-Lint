use strict;
use warnings;
use Perl::Lint::Policy::Subroutines::ProtectPrivateSubs;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Subroutines::ProtectPrivateSubs';

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
--- failures: 5
--- params:
--- input
Other::Package::_foo();
Other::Package->_bar();
Other::Package::_foo;
Other::Package->_bar;
$self->Other::Package::_baz();

===
--- dscr: basic passes
--- failures: 0
--- params:
--- input
package My::Self::_private;
use My::Self::_private;
require My::Self::_private;

===
--- dscr: Public methods called on non-public classes ok.
--- failures: 0
--- params:
--- input
# Used for distibution-private classes.

Foo::_Bar->baz();

===
--- dscr: Class methods invoked via __PACKAGE__ are always OK.
--- failures: 0
--- params:
--- input
__PACKAGE__->_private();

===
--- dscr: "shift" followed by private method call
--- failures: 0
--- params:
--- input
# See http://rt.cpan.org/Ticket/Display.html?id=34713
# Also, see the test case below for a counter example.

shift->_private_sub();
shift->_private_sub;

===
--- dscr: other builtin-function followed by private method call
--- failures: 2
--- params:
--- input
# See http://rt.cpan.org/Ticket/Display.html?id=34713

pop->_private_sub();
pop->_private_sub;

===
--- dscr: Difficult-to-detect pass
--- failures: 0
--- params:
--- input
# This one should be illegal, but it is too hard to distinguish from
# the next one, which is legal
$pkg->_foo();

$self->_bar();
$self->SUPER::_foo();

===
--- dscr: Exceptions from the POSIX module.
--- failures: 0
--- params:
--- input
POSIX::_PC_CHOWN_RESTRICTED();
POSIX::_PC_LINK_MAX();
POSIX::_PC_MAX_CANON();
POSIX::_PC_MAX_INPUT();
POSIX::_PC_NAME_MAX();
POSIX::_PC_NO_TRUNC();
POSIX::_PC_PATH_MAX();
POSIX::_PC_PIPE_BUF();
POSIX::_PC_VDISABLE();
POSIX::_POSIX_ARG_MAX();
POSIX::_POSIX_CHILD_MAX();
POSIX::_POSIX_CHOWN_RESTRICTED();
POSIX::_POSIX_JOB_CONTROL();
POSIX::_POSIX_LINK_MAX();
POSIX::_POSIX_MAX_CANON();
POSIX::_POSIX_MAX_INPUT();
POSIX::_POSIX_NAME_MAX();
POSIX::_POSIX_NGROUPS_MAX();
POSIX::_POSIX_NO_TRUNC();
POSIX::_POSIX_OPEN_MAX();
POSIX::_POSIX_PATH_MAX();
POSIX::_POSIX_PIPE_BUF();
POSIX::_POSIX_SAVED_IDS();
POSIX::_POSIX_SSIZE_MAX();
POSIX::_POSIX_STREAM_MAX();
POSIX::_POSIX_TZNAME_MAX();
POSIX::_POSIX_VDISABLE();
POSIX::_POSIX_VERSION();
POSIX::_SC_ARG_MAX();
POSIX::_SC_CHILD_MAX();
POSIX::_SC_CLK_TCK();
POSIX::_SC_JOB_CONTROL();
POSIX::_SC_NGROUPS_MAX();
POSIX::_SC_OPEN_MAX();
POSIX::_SC_PAGESIZE();
POSIX::_SC_SAVED_IDS();
POSIX::_SC_STREAM_MAX();
POSIX::_SC_TZNAME_MAX();
POSIX::_SC_VERSION();
POSIX::_exit();

===
--- dscr: User-configured exceptions.
--- failures: 0
--- params: {protect_private_subs => {allow => 'Other::Package::_foo Other::Package::_bar Other::Package::_baz'}}
--- input
Other::Package::_foo();
Other::Package->_bar();
Other::Package::_foo;
Other::Package->_bar;
$self->Other::Package::_baz();

===
--- dscr: private_name_regex passing
--- failures: 0
--- params: {protect_private_subs => {private_name_regex => '_(?!_)\w+'}}
--- input
Other::Package::__foo();
Other::Package->__bar();
Other::Package::__foo;
Other::Package->__bar;
$self->Other::Package::__baz();

===
--- dscr: private_name_regex failure
--- failures: 5
--- params: {protect_private_subs => {private_name_regex => '__\w+'}}
--- input
Other::Package::_foo();
Other::Package->_bar();
Other::Package::_foo;
Other::Package->_bar;
$self->Other::Package::_baz();

