use strict;
use warnings;
use Perl::Lint::Policy::RegularExpressions::ProhibitEnumeratedClasses;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'RegularExpressions::ProhibitEnumeratedClasses';

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
m/\w\d\p{Uppercase}/;
m/[\w\s]/;
m/\[A-Z]/;

===
--- dscr: allowed classes
--- failures: 0
--- params:
--- input
m/[B-Y]/;
m/[0-8]/;
m/[\x{ffef}]/; # for code coverage

===
--- dscr: basic failures
--- failures: 8
--- params:
--- input
m/[A-Z]/;      # \p{Uppercase}
m/[a-z]/;      # \p{Lowercase}
m/[0-9]/;      # \d
m/[A-Za-z0-9_]/;  # \w
m/[0-9a-z_A-Z]/;  # \w
m/[a-zA-Z]/;   # \p{Alphabetic}
m/[ \t\r\n\f]/;# \s
m/[\ \t\r\n]/; # \s

===
--- dscr: alterate representations of line endings
--- failures: 3
--- params:
--- input
m/[\ \t\012\015]/; # \s
m/[\ \t\x0a\x0d]/; # \s
m/[\ \t\x{0a}\x{0d}]/; # \s

===
--- dscr: negative failures
--- failures: 8
--- params:
--- input
m/[^\w]/;       # \W
m/[^\s]/;       # \S
m/[^0-9]/;      # \D
m/[^A-Za-z0-9_]/;  # \W
m/[^0-9a-z_A-Z]/;  # \W
m/[^a-zA-Z]/;   # \P{Alphabetic}
m/[^ \t\r\n\f]/;# \S
m/[^\ \t\r\n]/; # \S

===
--- dscr: special negative successes
--- failures: 0
--- params:
--- input
m/[^\s\w]/;

# TODO
# ===
# --- dscr: failing regexp with syntax error
# --- failures: 0
# --- params:
# --- input
# m/[^\w] (/;
#
