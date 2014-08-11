#!perl

use strict;
use warnings;
use Perl::Lint::Policy::Subroutines::ProhibitExplicitReturnUndef;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Subroutines::ProhibitExplicitReturnUndef';

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
--- dscr: simple failure
--- failures: 3
--- params:
--- input
sub test_sub1 {
    $foo = shift;
    return undef;
}

sub test_sub2 {
    shift || return undef;
}

sub test_sub3 {
    return undef if $bar;
}

===
--- dscr: simple success
--- failures: 0
--- params:
--- input
sub test_sub1 {
    $foo = shift;
    return;
}

sub test_sub2 {
    shift || return;
}

sub test_sub3 {
    return if $bar;
}

$foo{return}; # hash key, not keyword
sub foo {return}; # no sibling

