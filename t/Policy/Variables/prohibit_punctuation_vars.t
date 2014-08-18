use strict;
use warnings;
use Perl::Lint::Policy::Variables::ProhibitPunctuationVars;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Variables::ProhibitPunctuationVars';

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
--- failures: 3
--- params:
--- input
$/ = undef;
$| = 1;
$> = 3;

===
--- dscr: Basic failure (needs to be merged into prior test once PPI knows how to parse '%-'
--- failures: 1
--- params:
--- input
%- = (foo => 1);

===
--- dscr: English is nice
--- failures: 0
--- params:
--- input
$RS                     = undef;
$INPUT_RECORD_SEPARATOR = "\n";
$OUTPUT_AUTOFLUSH       = 1;
print $foo, $baz;

===
--- dscr: Permitted variables
--- failures: 0
--- params:
--- input
$string =~ /((foo)bar)/;
$foobar = $1;
$foo    = $2;
$3;
$stat = stat(_);
@list = @_;
my $line = $_;

my $perl_version = $];

===
--- dscr: Configuration
--- failures: 0
--- params: {prohibit_punctuation_vars => {allow => '$@ $!'}}
--- input
print $@;
print $!;

===
--- dscr: PPI::Token::Quote::Double Interpolation: violations
--- params: {prohibit_punctuation_vars => {allow => '$@ $!'}}
--- failures: 7
--- input
print "$+";
print "This is my $+. is it not nifty?";
print "This is my $+. is it not $@?";
print "this \n should $+\n violate";
print "as \n$+ should this";
print "${\($$)}";
print "${[$$]}";

===
--- dscr: PPI::Token::Quote::Double Interpolation: non-violations
--- params: {prohibit_punctuation_vars => {allow => '$@ $!'}}
--- failures: 0
--- input
print "\$+";
print "$@";
print "$!";
print "no magic here";
print "This is my $@; is it not nifty?";
print "but not \n\$+ this";

===
--- dscr: PPI::Token::Quote::Interpolate Interpolation: violations
--- failures: 3
--- params:
--- input
print qq<$+>;
print qq<\\$+>;
print qq<\\\\$+>;

===
--- dscr: PPI::Token::Quote::Interpolate Interpolation: non-violations
--- failures: 0
--- params:
--- input
print qq<\$+>;
print qq<\\\$+>;

===
--- dscr: PPI::Token::QuoteLike::Command: violations
--- failures: 1
--- params:
--- input
print qx<$+>;

===
--- dscr: PPI::Token::QuoteLike::Command: non-violations
--- failures: 0
--- params:
--- input
print qx<\$+>;

===
--- dscr: PPI::Token::QuoteLike::Backtick: violations
--- failures: 1
--- params:
--- input
print `$+`;

===
--- dscr: PPI::Token::QuoteLike::Backtick: non-violations
--- failures: 0
--- params:
--- input
print `\$+`;

===
--- dscr: PPI::Token::QuoteLike::Regexp: violations
--- failures: 1
--- params:
--- input
print qr<$+>;

===
--- dscr: PPI::Token::QuoteLike::Regexp: non-violations
--- failures: 0
--- params:
--- input
print qr<\$+>;

===
--- dscr: PPI::Token::QuoteLike::Readline: violations
--- failures: 1
--- params:
--- input
while (<$+>) { 1; }

===
--- dscr: PPI::Token::QuoteLike::Readline: non-violations
--- failures: 0
--- params:
--- input
while (<\$+>) { 1; }

# ===
# --- dscr: Heredoc Interpolation: violations
# --- failures: 11
# --- params: {prohibit_punctuation_vars => {allow => '$@ $!'}}
# --- input
# print <<DEFAULT;    # default, implied "" context
# $+
# DEFAULT
#
# print <<DEFAULT;    # default, implied "" context
# $+
# fred
# wilma
# DEFAULT
#
# print <<DEFAULT;    # default, implied "" context
# barney
# $+
# betty
# DEFAULT
#
# print <<DEFAULT;    # default, implied "" context
# $+
# pebbles
# bambam
# DEFAULT
#
# print <<"DOUBLE_QUOTE";    # explicit "" context
# $$
# DOUBLE_QUOTE
#
# print <<"DQ_VERYVERYVERY_LONG_HEREDOC_EOT_IDENTIFIER";   # explicit "" context
# $+
# DQ_VERYVERYVERY_LONG_HEREDOC_EOT_IDENTIFIER
#
# print <<"MULTI_MATCHES";                                 # explicit "" context
# $$
# $+
# $\
# $^A
# MULTI_MATCHES
#
# print <<`BACKTICK`;                                      # backtick context
# $+
# BACKTICK

# ===
# --- dscr: Heredoc Interpolation: non-violations
# --- failures: 0
# --- params: {prohibit_punctuation_vars => {allow => '$@ $!'}}
# --- input
# print <<DEFAULT_ALLOWED;    # default, implied "" but allowed var; should pass
# $@
# DEFAULT_ALLOWED
#
# print <<'SINGLE_QUOTE';     # '' context; should pass
# $?
# SINGLE_QUOTE

# ===
# --- dscr: Quoted String Interpolation wart cases
# --- failures: 0
# --- params:
# --- input
# ## TODO debug wart cases from String Interpolation exhaustive
# print "$"";      # 2 of 59
# print "$\";      # 28 of 59

===
--- dscr: Quoted String Interpolation - ignored magic vars
--- failures: 0
--- params: {prohibit_punctuation_vars => {string_mode => 'simple'}}
--- input
print "$#";    # 3 of 59  Exception made for $#
print "$$";    # 6 of 59  Exception made for $$
print "$'";    # 9 of 59  Exception made for $'
print "$:";    # 19 of 59  Exception made for $:

===
--- dscr: Quoted String Interpolation - exhaustive tests
--- failures: 54
--- params:
--- input
print "$!";    # 1 of 54

print qq{$"};    # 2 of 54
print "$#";      # 3 of 54
print "$#+";     # 4 of 54
print "$#-";     # 5 of 54
print "$$";      # 6 of 54
print "$%";      # 7 of 54
print "$&";      # 8 of 54
print "$'";      # 9 of 54
print "$(";      # 10 of 54
print "$)";      # 11 of 54
print "$*";      # 12 of 54
print "$+";      # 13 of 54
print "$,";      # 14 of 54
print "$-";      # 15 of 54
print "$.";      # 16 of 54
print "$/";      # 17 of 54
print "$0";      # 18 of 54
print "$:";      # 19 of 54
print "$::|";    # 20 of 54
print "$;";      # 21 of 54
print "$<";      # 22 of 54
print "$=";      # 23 of 54
print "$>";      # 24 of 54
print "$?";      # 25 of 54
print "$@";      # 26 of 54
print "$[";      # 27 of 54

print "$\\";     # 28 of 54
print "$^";      # 29 of 54
print "$^A";     # 30 of 54
print "$^C";     # 31 of 54
print "$^D";     # 32 of 54
print "$^E";     # 33 of 54
print "$^F";     # 34 of 54
print "$^H";     # 35 of 54
print "$^I";     # 36 of 54
print "$^L";     # 37 of 54
print "$^M";     # 38 of 54
print "$^N";     # 39 of 54
print "$^O";     # 40 of 54
print "$^P";     # 41 of 54
print "$^R";     # 42 of 54
print "$^S";     # 43 of 54
print "$^T";     # 44 of 54
print "$^V";     # 45 of 54
print "$^W";     # 46 of 54
print "$^X";     # 47 of 54
print "$`";      # 48 of 54
print "$|";      # 49 of 54
print "$}";      # 50 of 54
print "$~";      # 51 of 54
print "@*";      # 52 of 54
print "@+";      # 53 of 54
print "@-";      # 54 of 54

===
--- dscr: String Interpolation - 'disable' mode
--- failures: 0
--- params: {prohibit_punctuation_vars => {string_mode => 'disable'}}
--- input
print "$!";

===
--- dscr: String Interpolation - explicit 'simple' mode
--- failures: 6
--- params: {prohibit_punctuation_vars => {string_mode => 'simple'}}
--- input
print "$+";
print "This is my $+. is it not nifty?";
print "This is my $+. is it not $@?";
print "this \n should $+\n violate";
print "as \n$+ should this";

# ===
# --- dscr: String Interpolation - thorough-mode violations
# --- failures: 4
# --- params: {prohibit_punctuation_vars => {string_mode => 'thorough'}}
# --- input
# print "$!";
# print "this \n should $+\n violate";
# print <<"DOUBLE_QUOTE";    # explicit "" context
# $+with stuff
# $!more stuff
# $/thingy
# $$ $; $= $/
# DOUBLE_QUOTE
# print "blahblah ${\($$))}" # sneaky scalar dereference syntax

===
--- dscr: String Interpolation - thorough-mode special case violations
--- failures: 16
--- params: {prohibit_punctuation_vars => {string_mode => 'thorough'}}
--- input
# related to $', $:, and $_
print "$' ralph";
print "$'3";
print "$:";
print "$: ";
print "$:fred";
print "$: something else";

# related to $#
print "$#";

# related to $$
print "$$";
print "$$ foovar";
print "$$(foovar";

# related to $^
print "$^";
print "$^M";    # violates $^M
# print "$^G";  # violates $^ (there is no $^G), ignore
print "$^ foovar";
print "$^(foovar";

# sneakier combos
print "$::foo then $' followed by $'3"; # violates for $'
#                  ~~             ~~

===
--- dscr: String Interpolation - thorough-mode mixed multiple violations
--- failures: 4
--- params: {prohibit_punctuation_vars => {string_mode => 'thorough'}}
--- input
print "$::foo then $' followed by $'3 and $+ and $]";

===
--- dscr: String Interpolation - thorough-mode special case non-violations
--- failures: 0
--- params: {prohibit_punctuation_vars => {string_mode => 'thorough'}}
--- input
# related to $', $:, and $_
# print "$'global_symbol"; # TODO
print "$::global_symbol";
print "$::";
print "$:: ";
print "$:: something else";

print "$_varname";

# related to $#
# print "$#foovar"; # TODO
# print "$#$";      # TODO
print "$#{";

# related to $$
print "$$foovar";

# related to $^
#print "$^WIDE_SYSTEM_CALLS;

===
--- dscr: sprintf formats - RT #49016
--- failures: 0
--- params:
--- input
sprintf "%-03f\n", $foo;

===
--- dscr: trailing dollar sign is not a punctuation variable - RT #55604
--- failures: 0
--- params:
--- input
qr/foo$/

# ===
# --- dscr: detect bracketed punctuation variables - RT #72910
# --- failures: 0
# --- params: {prohibit_punctuation_vars => {allow => '$$'}}
# --- input
# "${$}";
#
