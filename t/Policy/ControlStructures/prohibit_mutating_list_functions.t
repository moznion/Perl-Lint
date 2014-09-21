use strict;
use warnings;
use Perl::Lint::Policy::ControlStructures::ProhibitMutatingListFunctions;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ControlStructures::ProhibitMutatingListFunctions';

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
--- dscr: Assignment and op-assignment
--- failures: 18
--- params:
--- input
@bar = map {$_++} @foo;
@bar = map {$_--} @foo;
@bar = map {$_ = 1} @foo;
@bar = map {$_ **= 2} @foo;
@bar = map {$_ += 2} @foo;
@bar = map {$_ *= 2} @foo;
@bar = map {$_ &= 2} @foo;
@bar = map {$_ <<= 2} @foo;
@bar = map {$_ &&= 2} @foo;
@bar = map {$_ -= 2} @foo;
@bar = map {$_ /= 2} @foo;
@bar = map {$_ |= 2} @foo;
@bar = map {$_ >>= 2} @foo;
@bar = map {$_ ||= 2} @foo;
@bar = map {$_ .= 2} @foo;
@bar = map {$_ %= 2} @foo;
@bar = map {$_ ^= 2} @foo;
@bar = map {$_ //= 2} @foo;
# @bar = map {$_ x= 2} @foo; # TODO

===
--- dscr: ++ and -- operators
--- failures: 2
--- params:
--- input
@bar = map {++$_} @foo;
@bar = map {--$_} @foo;

===
--- dscr: Explicit regexes
--- failures: 3
--- params:
--- input
@bar = map {$_ =~ s/f/g/} @foo;
@bar = map {$_ =~ tr/f/g/} @foo;
@bar = map {$_ =~ y/f/g/} @foo;

===
--- dscr: Simple implicit regexps
--- failures: 3
--- params:
--- input
@bar = map {s/f/g/} @foo;
@bar = map {tr/f/g/} @foo;
@bar = map {y/f/g/} @foo;

===
--- dscr: "Hidden" implicit regexps
--- failures: 3
--- params:
--- input
@bar = map {my $c = s/f/g/g; $c} @foo;
@bar = map {my $c = tr/f/g/g; $c} @foo;
@bar = map {my $c = y/f/g/g; $c} @foo;

===
--- dscr: Implicit chomp-ish builtins
--- failures: 4
--- params:
--- input
@bar = map {chop} @foo;
@bar = map {chomp} @foo;
@bar = map {undef} @foo;
@bar = map {chop()} @foo;
@bar = map {chomp()} @foo;
@bar = map {undef()} @foo;

===
--- dscr: Explicit chomp-ish builtins
--- failures: 6
--- params:
--- input
@bar = map {chop $_} @foo;
@bar = map {chomp $_} @foo;
@bar = map {undef $_} @foo;
@bar = map {chop($_)} @foo;
@bar = map {chomp($_)} @foo;
@bar = map {undef($_)} @foo;

===
--- dscr: substr
--- failures: 1
--- params:
--- input
@bar = map {substr $_, 0, 1, 'f'} @foo;

===
--- dscr: Non-mutators
--- failures: 0
--- params:
--- input
@bar = map {$_} @foo;
@bar = map {$_ => 1} @foo;
@bar = map {m/4/} @foo;
@bar = map {my $s=$_; chomp $s; $s} @foo;

===
--- dscr: Value given for list_funcs passing
--- failures: 0
--- params: {prohibit_mutating_list_functions => {list_funcs => ' foo bar '}}
--- input
@bar = map {$_=1} @foo;
@bar = foo {$_} @foo;
@bar = baz {$_=1} @foo;

===
--- dscr: Value given for list_funcs failure
--- failures: 1
--- params: {prohibit_mutating_list_functions => {list_funcs => ' foo bar '}}
--- input
@bar = foo {$_=1} @foo;

===
--- dscr: Value given for add_list_funcs
--- failures: 2
--- params: {prohibit_mutating_list_functions => {add_list_funcs => ' foo bar '}}
--- input
@bar = map {$_=1} @foo;
@bar = foo {$_=1} @foo;

===
--- dscr: Accept non-mutating tr/// function. RT 44515
--- failures: 0
--- params:
--- input
@bar = map {$_ =~ tr/f//} @foo;
@bar = map {$_ =~ tr/f//c} @foo;
@bar = map {$_ =~ tr/f/f/} @foo;
@bar = map {$_ =~ tr/f/f/d} @foo;
@bar = map {$_ =~ y/f//} @foo;
@bar = map {$_ =~ y/f//c} @foo;
@bar = map {$_ =~ y/f/f/} @foo;
@bar = map {$_ =~ y/f/f/d} @foo;
@bar = map {tr/f//} @foo;
@bar = map {tr/f//c} @foo;
@bar = map {tr/f/f/} @foo;
@bar = map {tr/f/f/d} @foo;
@bar = map {y/f//} @foo;
@bar = map {y/f//c} @foo;
@bar = map {y/f/f/} @foo;
@bar = map {y/f/f/d} @foo;
@bar = map {my $c = tr/f//; $c} @foo;
@bar = map {my $c = tr/f//c; $c} @foo;
@bar = map {my $c = tr/f/f/; $c} @foo;
@bar = map {my $c = tr/f/f/d; $c} @foo;
@bar = map {my $c = y/f//; $c} @foo;
@bar = map {my $c = y/f//c; $c} @foo;
@bar = map {my $c = y/f/f/; $c} @foo;
@bar = map {my $c = y/f/f/d; $c} @foo;

===
--- dscr: Recognize mutating tr/// function. RT 44515
--- failures: 24
--- params:
--- input
@bar = map {$_ =~ tr/f//d} @foo;
@bar = map {$_ =~ tr/f/f/c} @foo;
@bar = map {$_ =~ tr/f//s} @foo;
@bar = map {$_ =~ tr/f/f/s} @foo;
@bar = map {$_ =~ y/f//d} @foo;
@bar = map {$_ =~ y/f/f/c} @foo;
@bar = map {$_ =~ y/f//s} @foo;
@bar = map {$_ =~ y/f/f/s} @foo;
@bar = map {tr/f//d} @foo;
@bar = map {tr/f/f/c} @foo;
@bar = map {tr/f//s} @foo;
@bar = map {tr/f/f/s} @foo;
@bar = map {y/f//d} @foo;
@bar = map {y/f/f/c} @foo;
@bar = map {y/f//s} @foo;
@bar = map {y/f/f/s} @foo;
@bar = map {my $c = tr/f//d; $c} @foo;
@bar = map {my $c = tr/f/f/c; $c} @foo;
@bar = map {my $c = tr/f//s; $c} @foo;
@bar = map {my $c = tr/f/f/s; $c} @foo;
@bar = map {my $c = y/f//d; $c} @foo;
@bar = map {my $c = y/f/f/c; $c} @foo;
@bar = map {my $c = y/f//s; $c} @foo;
@bar = map {my $c = y/f/f/s; $c} @foo;

===
--- dscr: Recognize non-mutating s///r function introduced in 5.13.2.
--- failures: 0
--- params:
--- input
@bar = map { s/cat/dog/r } @foo;

===
--- dscr: Recognize non-mutating tr///r function introduced in 5.13.7.
--- failures: 0
--- params:
--- input
@bar = map { tr/cat/dog/r } @foo;
@bar = map { y/cat/dog/r } @foo;

