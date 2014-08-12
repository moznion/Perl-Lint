use strict;
use warnings;
use Perl::Lint::Policy::RegularExpressions::ProhibitEscapedMetacharacters;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'RegularExpressions::ProhibitEscapedMetacharacters';

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
m/ [{] . [.] \d{2} [}] /xms;
$name =~ m{ harry [ ] s [ ] truman
          | harry [ ] j [ ] potter
          }ixms;
m/ [{] /xms;
m/ [}] /xms;
m/ [(] /xms;
m/ [)] /xms;
m/ [.] /xms;
m/ [*] /xms;
m/ [+] /xms;
m/ [?] /xms;
m/ [|] /xms;
m/ [#] /xms;
m/ [ ] /xms;

s/ [{] //xms;

===
--- dscr: basic failures
--- failures: 14
--- params:
--- input
m/ \{ . \. \d{2} \} /xms;
$name =~ m{ harry \ s \ truman
          | harry \ j \ potter
          }ixms;
m/ \{ /xms;
m/ \} /xms;
m/ \( /xms;
m/ \) /xms;
m/ \. /xms;
m/ \* /xms;
m/ \+ /xms;
m/ \? /xms;
m/ \| /xms;
m/ \  /xms;
m/\#/ms;

s/ \{ //xms;

===
--- dscr: allow comment character in //x mode -- http://rt.perl.org/rt3/Public/Bug/Display.html?id=45667
--- failures: 0
--- params:
--- input
m/\#/x;
s/\#//x;
s{\#}{}x;

===
--- dscr: allowed escapes
--- failures: 0
--- params:
--- input
# omit \N{}, \p{}, \P{}, \xfe \cx
m/\Q\E \L\U \l\u /;  # matched pairs of specials
m/\A\B\C\D  \F\G\H\I\J\K \M  \O   \R\S\T \V\W\X\Y\Z /;
m/\a\b  \d\e\f\g\h\i\j\k \m\n\o \q\r\s\t \v\w  \y\z /;
m/(.)(.)(.)(.)(.)(.)(.)(.)(.)
  \1\2\3\4\5\6\7\8\9 /;
m/\!\@\%\&\-\_\= /;
m/\\ \'\"\` \~\,\<\> \/ /;
m/ \[\] /x;

===
--- dscr: unexpected failures
--- failures: 0
--- params:
--- input
s{\%[fF]}{STDIN}mx;

===
--- dscr: escaped characters in character classes
--- failures: 2
--- params:
--- input
m/ ([\)]) /xms;
m/ [\.] /xms;

===
--- dscr: ignore reg quote
--- failures: 0
--- params:
--- input
q/ \{ /;
qq/ \} /;

