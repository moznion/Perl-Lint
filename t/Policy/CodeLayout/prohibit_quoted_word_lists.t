use strict;
use warnings;
use Perl::Lint::Policy::CodeLayout::ProhibitQuotedWordLists;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'CodeLayout::ProhibitQuotedWordLists';

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
--- failures: 2
--- params:
--- input
@list = ('foo', 'bar', 'baz-bot');

@list = ('foo',
         'bar',
         'baz-bot');

===
--- dscr: Non-word lists
--- failures: 0
--- params:
--- input
@list = ('3/4', '-123', '#@$%');

@list = ('3/4',
         '-123',
         '#@$%');

===
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
('foo');
@list = ();
@list = ('foo');
@list = ('foo', 'bar', 'bee baz');
@list = ('foo', 'bar', q{bee baz});
@list = ('foo', 'bar', q{});
@list = ('foo', 'bar', 1.0);
@list = ('foo', 'bar', 'foo'.'bar');
@list = ($foo, 'bar', 'baz');
@list = (foo => 'bar');
%hash = ('foo' => 'bar', 'fo' => 'fum');
my_function('foo', 'bar', 'fudge');
&my_function('foo', 'bar', 'fudge');
$an_object->a_method('foo', 'bar', 'fudge');
$a_sub_routine_ref->('foo', 'bar', 'fudge');
foreach ('foo', 'bar', 'nuts'){ do_something($_) }

===
--- dscr: Three elements with minimum set to four
--- failures: 0
--- params: {prohibit_quoted_word_lists => {min_elements => 4}}
--- input
@list = ('foo', 'bar', 'baz');

===
--- dscr: Four elements with minimum set to four
--- failures: 1
--- params: {prohibit_quoted_word_lists => {min_elements => 4}}
--- input
@list = ('foo', 'bar', 'baz', 'nuts');

===
--- dscr: Failing 'use' statements
--- failures: 1
--- params:
--- input
use Foo ('foo', 'bar', 'baz');

===
--- dscr: Passing 'use' statements
--- failures: 0
--- params:
--- input
use Foo ();
use Foo ('foo', 1, 'bar', '1/2');
use Foo ('foo' => 'bar', 'baz' => 'nuts');

===
--- dscr: Non-word lists in strict mode.
--- failures: 3
--- params: {prohibit_quoted_word_lists => {strict => 1}}
--- input
use Foo ('foo', 'bar', '1/2');

@list = ('3/4', '-123', '#@$%');

@list = ('3/4',
         '-123',
         '#@$%');

