use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::RequireSimpleSortBlock;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::RequireSimpleSortBlock';

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
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
sort @list;
sort {$a cmp $b;} @list;
sort {$a->[0] <=> $b->[0] && $a->[1] <=> $b->[1]} @list;
sort {bar($a,$b)} @list;
sort 'func', @list;

sort(@list);
sort({$a cmp $b;} @list);
sort({$a->[0] <=> $b->[0] && $a->[1] <=> $b->[1]} @list);
sort({bar($a,$b)} @list);
sort('func', @list);

$foo{sort}; # for Devel::Cover
{sort}; # for Devel::Cover
sort();

===
--- dscr: Basic failure
--- failures: 1
--- params:
--- input
sort {my $aa = $foo{$a};my $b = $foo{$b};$a cmp $b} @list;

===
--- dscr: Potential false positives
--- failures: 0
--- params:
--- input
# These are things I found in my Perl that caused some false-
# positives because they have some extra whitespace in the block.

sort { $a->[2] cmp $b->[2] } @dl;
sort { $a->[0] <=> $b->[0] } @failed;
sort{ $isopen{$a}->[0] <=> $isopen{$b}->[0] } @list;
sort { -M $b <=> -M $a} @entries;

