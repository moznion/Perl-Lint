#!perl

use strict;
use warnings;
use Perl::Lint::Policy::Subroutines::ProhibitReturnSort;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Subroutines::ProhibitReturnSort';

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
--- failures: 6
--- params:
--- input
sub test_sub1 {
    return sort @list;
    return sort(@list);
}

sub test_sub2 {
    return sort { $a <=> $b } @list;
    return sort({ $a <=> $b } @list);
}

sub test_sub3 {
    return sort @list  if $bar;
    return sort(@list) if $bar;
}

===
--- dscr: simple success
--- failures: 0
--- params:
--- input
sub test_sub1 {
    @sorted = sort @list;
    return @sorted;
}

sub test_sub2 {
    return wantarray ? sort @list : $foo;
}

sub test_sub3 {
    return map {func($_)} sort @list;
}

===
--- dscr: when used in conjunction with wantarray()
--- failures: 0
--- params:
--- input
sub test_sub1 {
    if (wantarray) {
        return sort @list;
    }
}
sub test_sub2 {
    return sort @list if wantarray;
}

===
--- dscr: "sort" used in other contexts...
--- failures: 0
--- params:
--- input
$foo{sort}; # hash key, not keyword
sub foo {return}; # no sibling
