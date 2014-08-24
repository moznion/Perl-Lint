use strict;
use warnings;
use Perl::Lint::Policy::Variables::RequireNegativeIndices;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Variables::RequireNegativeIndices';

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
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
$arr[-1];
$arr[ -2 ];
$arr[$m-$n];
$arr[@foo-1];
$arr[$#foo-1];
$arr[@$arr-1];
$arr[$#$arr-1];
1+$arr[$#{$arr}-1];
$arr->[-1];
$arr->[ -2 ];
3+$arr->[@foo-1 ];
# $arr->[@arr-1 ];
$arr->[ $#foo - 2 ];
$$arr[-1];
$$arr[ -2 ];
$$arr[@foo-1 ];
$$arr[@arr-1 ];
$$arr[ $#foo - 2 ];

===
--- dscr: Basic failure
--- failures: 5
--- params:
--- input
$arr[$#arr];
$arr[$#arr-1];
$arr[ $#arr - 2 ];
$arr[@arr-1];
$arr[@arr - 2];

===
--- dscr: Complex failures
--- failures: 8
--- params:
--- input
$arr_ref->[$#{$arr_ref}-1];
$arr_ref->[$#$arr_ref-1];
$arr_ref->[@{$arr_ref}-1];
$arr_ref->[@$arr_ref-1];
$$arr_ref[$#{$arr_ref}-1];
$$arr_ref[$#$arr_ref-1];
$$arr_ref[@{$arr_ref}-1];
$$arr_ref[@$arr_ref-1];

===
--- dscr: Really hard failures that we can't detect yet
--- failures: 0
--- params:
--- input
# These ones are too hard to detect for now; FIXME??
$some->{complicated}->[$data_structure]->[$#{$some->{complicated}->[$data_structure]} -1];
my $ref = $some->{complicated}->[$data_structure];
$some->{complicated}->[$data_structure]->[$#{$ref} -1];
$ref->[$#{$some->{complicated}->[$data_structure]} -1];

