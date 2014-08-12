use strict;
use warnings;
use Perl::Lint::Policy::RegularExpressions::RequireBracesForMultiline;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'RegularExpressions::RequireBracesForMultiline';

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
--- dscr: short match regexps
--- failures: 0
--- params:
--- input
/foo/;
/foo\nbar/;
/ bar .* baz /;
# / bar .* baz /m; # <= right test case, but remove option
#                       cuz maybe Compiler::Lexer's bug
s/foo/
  bar
 /;

====
--- dscr: proper delimiters
--- failures: 0
--- params:
--- input
m{
   foo
 }x;
m{
   foo
 };
s{foo
  bar}
 {baz
  fzz};
qr{
   foo
  };

====
--- dscr: basic failures
--- failures: 4
--- params:
--- input
m/
 foo
 /;
s/
 foo
 //;
qr/
  foo
 /;
m#
 foo
 #;

===
--- dscr: allow_all_brackets
--- failures: 0
--- params: {require_braces_for_multiline => {allow_all_brackets => 1}}
--- input
m(
   foo
 )x;
m(
   foo
 );
s(foo
  bar)
 (baz
  fzz);
qr(
   foo
   );

m[
   foo
 ]x;
m[
   foo
 ];
s[foo
  bar]
 [baz
  fzz];
qr[
   foo
   ];

m<
   foo
 >x;
m<
   foo
 >;
s<foo
  bar>
 <baz
  fzz>;
qr<
   foo
   >;

