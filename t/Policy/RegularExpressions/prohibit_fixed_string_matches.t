use strict;
use warnings;
use Perl::Lint::Policy::RegularExpressions::ProhibitFixedStringMatches;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'RegularExpressions::ProhibitFixedStringMatches';

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
/foo/;
/foo/s;
/ bar /;
/(bar)/;
/(foo|bar)/;

s/foo//;
qr/ bar /;

===
--- dscr: failures mentioned in perldoc
--- failures: 7
--- params:
--- input
m/^foo$/;
m/\A foo \z/x;
m/\A foo \z/xm;
m/\A(foo)\z/;
m/\A(?:foo)\z/;
m/\A(foo|bar)\z/;
m/\A(?:foo|bar)\z/;

===
--- dscr: anchored passes
--- failures: 0
--- params:
--- input
/\A \s* \z/sx;
/ \A \s* \z /sx;
/^ \w+ $/x;
/^ foo $/mx;

s/\A \s* \z//sx;
s/^ \w+ $//x;
s/^ foo $//mx;
#           ~ workaround

qr/\A \s* \z/s;
qr/^ \w+ $/x;
qr/^ foo $/mx;
#           ~ workaround

===
--- dscr: escapes
--- failures: 0
--- params:
--- input
/\\A foo \\z/s;
/\^ foo \$/;

===
--- dscr: alternating passes
--- failures: 0
--- params:
--- input
/\A (foo|\w+) \z/x;
/^ (foo|bar) \z/mx;

===
--- dscr: basic failures, m//
--- failures: 5
--- params:
--- input
/\A foo \z/x;
/\A foo \z/s;
/\A foo \z/xs;
/^ foo $/sx;
/\A foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo \z/;

===
--- dscr: basic failures, s///
--- failures: 5
--- params:
--- input
s/\A foo \z//;
s/\A foo \z//s;
s/\A foo \z//xs;
s/^ foo $//s;
s/\A foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo \z//;

===
--- dscr: basic failures, qr//
--- failures: 5
--- params:
--- input
qr/\A foo \z/;
qr/\A foo \z/s;
qr/\A foo \z/xs;
qr/^ foo $/s;
qr/\A foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo \z/;

===
--- dscr: alternating failures
--- failures: 5
--- params:
--- input
qr/\A(foo|bar)\z/;
qr/\A(foo|)\z/;
qr/\A(?:foo|bar)\z/;
/^(?:foo|bar)$/;
/^(?:foo|bar|baz|spam|splunge)$/;

===
--- dscr: ignore with reg quote
--- failures: 0
--- params:
--- input
q{\A foo \z};
q{\A foo \z};
q{\A foo \z};
q{^ foo $};
q{\A foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo \z};
qq{\A foo \z};
qq{\A foo \z};
qq{\A foo \z};
qq{^ foo $};
qq{\A foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo foo \z};
