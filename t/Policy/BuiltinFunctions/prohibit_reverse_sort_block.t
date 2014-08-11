use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::ProhibitReverseSortBlock;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::ProhibitReverseSortBlock';

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
reverse sort {$a <=> $b} @list;
reverse sort {$a->[0] <=> $b->[0] && $a->[1] <=> $b->[1]} @list;
sort {$beta{$a} <=> $alpha{$b}} @list;
reverse sort({$a <=> $b} @list);
reverse sort({$a->[0] <=> $b->[0] && $a->[1] <=> $b->[1]} @list);
sort({$beta{$a} <=> $alpha{$b}} @list);

sort{ $isopen{$a}->[0] <=> $isopen{$b}->[0] } @list;

===
--- dscr: Basic passing /w cmp
--- failures: 0
--- params:
--- input
reverse sort {$a cmp $b} @list;
reverse sort {$a->[0] cmp $b->[0] && $a->[1] cmp $b->[1]} @list;
sort {$beta{$a} cmp $alpha{$b}} @list;
reverse sort({$a cmp $b} @list);
reverse sort({$a->[0] cmp $b->[0] && $a->[1] cmp $b->[1]} @list);
sort({$beta{$a} cmp $alpha{$b}} @list);

sort{ $isopen{$a}->[0] cmp $isopen{$b}->[0] } @list;

===
--- dscr: Basic failure
--- failures: 3
--- params:
--- input
sort {$b <=> $a} @list;
sort {$alpha{$b} <=> $beta{$a}} @list;
sort {$b->[0] <=> $a->[0] && $b->[1] <=> $a->[1]} @list;

===
--- dscr: Basic failure w/ cmp
--- failures: 3
--- params:
--- input
sort {$b cmp $a} @list;
sort {$alpha{$b} cmp $beta{$a}} @list;
sort {$b->[0] cmp $a->[0] && $b->[1] cmp $a->[1]} @list;

===
--- dscr: Things that might look like sorts, but aren't, and sorts not involving $a and $b.
--- failures: 0
--- params:
--- input
$hash1{sort} = { $b <=> $a };
%hash2 = (sort => { $b <=> $a });
$foo->sort({ $b <=> $a });
sub sort { $b <=> $a }
sort 'some_sort_func', @list;
sort('some_sort_func', @list);
sort();

{sort}; # for Devel::Cover

is( pcritique($policy, \$code), 0, $policy );

===
--- dscr: Things that might look like sorts, but aren't, and sorts not involving $a and $b w/ cmp
--- failures: 0
--- params:
--- input
$hash1{sort} = { $b cmp $a };
%hash2 = (sort => { $b cmp $a });
$foo->sort({ $b cmp $a });
sub sort { $b cmp $a }
sort 'some_sort_func', @list;
sort('some_sort_func', @list);
sort();

{sort}; # for Devel::Cover

is( pcritique($policy, \$code), 0, $policy );

