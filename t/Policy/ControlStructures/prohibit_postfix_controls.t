use strict;
use warnings;
use Perl::Lint::Policy::ControlStructures::ProhibitPostfixControls;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ControlStructures::ProhibitPostfixControls';

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
--- dscr: Basic failure
--- failures: 7
--- params:
--- input
do_something() if $condition;
do_something() while $condition;
do_something() until $condition;
do_something() unless $condition;
do_something() for @list;
do_something() foreach @list;
do_something() when @list;

===
--- dscr: Configured to allow all
--- failures: 0
--- params: {prohibit_postfix_controls => {allow => 'if while until unless for foreach when'}}
--- input
do_something() if $condition;
do_something() while $condition;
do_something() until $condition;
do_something() unless $condition;
do_something() for @list;
do_something() foreach @list;
do_something() when @list;

===
--- dscr: Configured to allow all, all regular control structures
--- failures: 0
--- params:
--- input
if($condition){ do_something() }
while($condition){ do_something() }
until($condition){ do_something() }
unless($condition){ do_something() }
when($smart_match){ do_something() }

===
--- dscr: Regular for loops
--- failures: 0
--- params:
--- input
# PPI versions < 1.03 had problems with this
for my $element (@list){ do_something() }
for (@list){ do_something_else() }
foreach my $element (@list){ do_something() }
foreach (@list){ do_something_else() }

===
--- dscr: Regular given/when
--- failures: 0
--- params:
--- input
given ($foo) {
    when ($bar) {
        $thingy = $blah;
    }
}

===
--- dscr: Legal postfix if usage
--- failures: 0
--- params:
--- input
use Carp;

while ($condition) {
    next if $condition;
    last if $condition;
    redo if $condition;
    return if $condition;
    goto HELL if $condition;
    exit if $condition;
}

die 'message' if $condition;
die if $condition;

warn 'message' if $condition;
warn if $condition;

carp 'message' if $condition;
carp if $condition;

croak 'message' if $condition;
croak if $condition;

cluck 'message' if $condition;
cluck if $condition;

confess 'message' if $condition;
confess if $condition;

exit 0 if $condition;
exit if $condition;

===
--- dscr: Legal postfix when usage
--- failures: 0
--- params:
--- input
use Carp;

while ($condition) {
    next when $smart_match;
    last when $smart_match;
    redo when $smart_match;
    return when $smart_match;
    goto HELL when $smart_match;
    exit when $smart_match;
}

die 'message' when $smart_match;
die when $smart_match;

warn 'message' when $smart_match;
warn when $smart_match;

carp 'message' when $smart_match;
carp when $smart_match;

croak 'message' when $smart_match;
croak when $smart_match;

cluck 'message' when $smart_match;
cluck when $smart_match;

confess 'message' when $smart_match;
confess when $smart_match;

exit 0 when $smart_match;
exit when $smart_match;

===
--- dscr: override exempt flowcontrols
--- failures: 0
--- params: {prohibit_postfix_controls => {flowcontrol => 'assert'}}
--- input
use Carp::Assert;

assert $something if $condition;

===
--- dscr: overriding exempt flowcontrols restores the defaults
--- failures: 8
--- params: {prohibit_postfix_controls => {flowcontrol => 'assert'}}
--- input
use Carp::Assert;

warn    $something if $condition;
die     $something if $condition;
carp    $something if $condition;
croak   $something if $condition;
cluck   $something if $condition;
confess $something if $condition;
exit    $something if $condition;
do_something() if $condition;

===
--- dscr: Individual "keyword" hash assignment
--- failures: 0
--- params:
--- input
my %hash;
$hash{if} = 1;
$hash{unless} = 1;
$hash{until} = 1;
$hash{while} = 1;
$hash{for} = 1;
$hash{foreach} = 1;
$hash{when} = 1;

===
--- dscr: "Keyword"-list hash assignment
--- failures: 0
--- params:
--- input
my %hash = (
    if      => 1,
    unless  => 1,
    until   => 1,
    while   => 1,
    for     => 1,
    foreach => 1,
    when    => 1,
);

===
--- dscr: RT #48422: Allow flow control method calls
--- failures: 0
--- params:
--- input
## TODO exemption for method calls not implimented yet
Exception::Class->throw('an expression') if $error;
Exception::Class->throw($arg1, $arg2) unless not $error;

