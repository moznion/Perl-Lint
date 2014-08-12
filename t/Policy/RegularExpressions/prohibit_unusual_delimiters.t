#!perl

use strict;
use warnings;
use Perl::Lint::Policy::RegularExpressions::ProhibitUnusualDelimiters;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'RegularExpressions::ProhibitUnusualDelimiters';

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
--- dscr: basic passes
--- failures: 0
--- params:
--- input
m/foo/;
m{foo};
s/foo//;
s{foo}{};
qr/foo/;
qr{foo};

===
--- dscr: basic failures
--- failures: 18
--- params:
--- input
m#foo#;
m|foo|;
m<foo>;
m(foo);

# m'foo'; TODO
# m"foo"; TODO

m;foo;;
m,foo,;

s#foo##;
s|foo||;
s<foo><>;
s(foo)();

# s'foo''; TODO
# s"foo""; TODO

s;foo;;;
s,foo,,;

qr#foo#;
qr|foo|;
qr<foo>;
qr(foo);

# qr'foo'; TODO
# qr"foo"; TODO

qr;foo;;
qr,foo,;

===
--- dscr: allow_all_brackets
--- failures: 0
--- params: {prohibit_unusual_delimiters => {allow_all_brackets => 1}}
--- input
m{foo};
m(foo);
m[foo];
m<foo>;

s{foo}{};
s(foo){};
s[foo]{};
s<foo>{};

s{foo}();
s(foo)();
s[foo]();
s<foo>();

s{foo}[];
s(foo)[];
s[foo][];
s<foo>[];

s{foo}<>;
s(foo)<>;
s[foo]<>;
s<foo><>;

