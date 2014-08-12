use strict;
use warnings;
use Perl::Lint::Policy::RegularExpressions::ProhibitComplexRegexes;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'RegularExpressions::ProhibitComplexRegexes';

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
--- dscr: basic passes
--- failures: 0
--- params:
--- input
m/foo/;
m/foo foo foo foo foo foo foo foo foo foo foo foo/;
m/foo
  foo/;

m/foo # this is a foo
  bar # this is a bar
  baz # this is a baz
  more # more more more more more
 /x;

m/





/;

===
--- dscr: basic failures
--- failures: 1
--- params:
--- input
m/ foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo/;

===
--- dscr: basic failures, m//x
--- failures: 1
--- params:
--- input
m/foo # this is a foo
  bar # this is a bar
  baz # this is a baz
  1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 # this is too long
 /x;

===
--- dscr: config
--- failures: 1
--- params: {prohibit_complex_regexes => {max_characters => 2}}
--- input
m/ foo /;

===
--- dscr: failing regexp with syntax error
--- failures: 0
--- params:
--- input
m/foofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoofoo(/x;

===
--- dscr: RT 36098 forgive long (and presumably descriptive) variable names
--- failures: 0
--- params: {prohibit_complex_regexes => {max_characters => 20}}
--- input
m/ $now_is_the_time_for_all_good_men_to_come_to /;
m/ \\$now_is_the_time_for_all_good_men_to_come_to /;
m/ $now::is::the::time::for::all::good::men::to::come::to /;
m/ ${^_now_is_the_time_for_all_good_men_to_come_to} /;
m/ ${now_is_the_time_for_all_good_men_to_come_to} /;
m/ ${now::is::the::time::for::all::good::men::to::come::to} /;
m/ @now_is_the_time_for_all_good_men_to_come_to /;
m/ @{^_now_is_the_time_for_all_good_men_to_come_to} /;
m/ @{now_is_the_time_for_all_good_men_to_come_to} /;
m/ @{now::is::the::time::for::all::good::men::to::come::to} /;
m/ $#now_is_the_time_for_all_good_men_to_come_to /;
m/ $#{^_now_is_the_time_for_all_good_men_to_come_to} /;

===
--- dscr: RT 36098 things that look like interpolation but are not
--- failures: 3
--- params: {prohibit_complex_regexes => {max_characters => 20}}
--- input
m/ \$now_is_the_time_for_all_good_men_to_come_to /;
m/ \\\$now_is_the_time_for_all_good_men_to_come_to /;
m' $now_is_the_time_for_all_good_men_to_come_to ';

===
--- dscr: pass with reg quote
--- failures: 0
--- params:
--- input
q{ foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo};
qq{ foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo};

