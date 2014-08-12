use strict;
use warnings;
use Perl::Lint::Policy::RegularExpressions::RequireExtendedFormatting;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'RegularExpressions::RequireExtendedFormatting';

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
# TODO ?
# my $string =~ m{pattern};
# my $string =~ m{pattern}gim;
# my $string =~ m{pattern}gis;
# my $string =~ m{pattern}gms;

my $string =~ m{pattern.}x;
my $string =~ m{pattern.}gimx;
my $string =~ m{pattern.}gixs;
my $string =~ m{pattern.}xgms;

my $string =~ m/pattern./x;
my $string =~ m/pattern./gimx;
my $string =~ m/pattern./gixs;
my $string =~ m/pattern./xgms;

my $string =~ /pattern./x;
my $string =~ /pattern./gimx;
my $string =~ /pattern./gixs;
my $string =~ /pattern./xgms;

my $string =~ s/pattern./foo/x;
my $string =~ s/pattern./foo/gimx;
my $string =~ s/pattern./foo/gixs;
my $string =~ s/pattern./foo/xgms;

# TODO ?
# my $string =~ s/pattern/foo./;
# my $string =~ s/pattern/foo./gim;
# my $string =~ s/pattern/foo./gis;
# my $string =~ s/pattern/foo./gms;

my $re =~ qr/pattern./x;

===
--- dscr: basic failures
--- failures: 17
--- params:
--- input
my $string =~ m{pattern.};
my $string =~ m{pattern.}gim;
my $string =~ m{pattern.}gis;
my $string =~ m{pattern.}gms;

my $string =~ m/pattern./;
my $string =~ m/pattern./gim;
my $string =~ m/pattern./gis;
my $string =~ m/pattern./gms;

my $string =~ /pattern./;
my $string =~ /pattern./gim;
my $string =~ /pattern./gis;
my $string =~ /pattern./gms;

my $string =~ s/pattern./foo/;
my $string =~ s/pattern./foo/gim;
my $string =~ s/pattern./foo/gis;
my $string =~ s/pattern./foo/gms;

my $re =~ qr/pattern./;

===
--- dscr: tr and y formatting
--- failures: 0
--- params:
--- input
my $string =~ tr/[A-Z]/[a-z]/;
my $string =~ tr|[A-Z]|[a-z]|;
my $string =~ tr{[A-Z]}{[a-z]};

my $string =~ y/[A-Z]/[a-z]/;
my $string =~ y|[A-Z]|[a-z]|;
my $string =~ y{[A-Z]}{[a-z]};

my $string =~ tr/[A-Z]/[a-z]/cds;
my $string =~ y/[A-Z]/[a-z]/cds;

===
--- dscr: minimum_regex_length_to_complain_about, pass
--- failures: 0
--- params: {require_extended_formatting => {minimum_regex_length_to_complain_about => 5}}
--- input
my $string =~ m/foo./;

my $string =~ s/foo.//;
my $string =~ s/foo./bar/;
my $string =~ s/foo./barbarbar/;
my $string =~ s/1234.//;

===
--- dscr: minimum_regex_length_to_complain_about, fail
--- failures: 2
--- params: {require_extended_formatting => {minimum_regex_length_to_complain_about => 5}}
--- input
my $string =~ m/fooba./;

my $string =~ s/fooba.//;

===
--- dscr: strict
--- failures: 2
--- params: {require_extended_formatting => {strict => 1}}
--- input
my $string =~ m/foobar/;

my $string =~ s/foobar/foo bar/;

===
--- dscr: use re '/x' - RT #72151
--- failures: 0
--- params:
--- input
use re '/x';
my $string =~ m{pattern.};

===
--- dscr: use re qw{ /x } - RT #72151
--- failures: 0
--- params:
--- input
use re qw{ /x };
my $string =~ m{pattern.};

===
--- dscr: use re qw{ /x } not in scope - RT #72151
--- failures: 1
--- params:
--- input
{
    use re qw{ /x };
}
my $string =~ m{pattern.};

===
--- dscr: no re qw{ /x } - RT #72151
--- failures: 1
--- params:
--- input
use re qw{ /smx };
{
    no re qw{ /x };
    my $string =~ m{pattern.};
}

