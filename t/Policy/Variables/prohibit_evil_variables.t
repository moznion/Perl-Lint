use strict;
use warnings;
use Perl::Lint::Policy::Variables::ProhibitEvilVariables;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Variables::ProhibitEvilVariables';

filters {
    params => [qw/eval/], # TODO wrong!
};

for my $block (blocks) {
    my $violations = fetch_violations($class_name, $block->input, $block->params);
    is scalar @$violations, $block->failures, $block->dscr;
}

subtest 'error handling for regex that has invalid syntax' => sub {
    eval {
        fetch_violations($class_name, <<'...', {prohibit_evil_variables => {variables => '/(/'}});
print 'Hello World';
...
    };

    my $e = $@;
    ok $e;
    like $e, qr/invalid regular expression/;
};

done_testing;

__DATA__

===
--- dscr: 2 evil variables
--- failures: 2
--- params: {prohibit_evil_variables => {variables => '$[ $SIG{__DIE__}'}}
--- input
print 'First subscript is ', $[, "\n";
local $SIG{__DIE__} = sub {warn "I cannot die!"};

===
--- dscr: plain evil variables
--- failures: 2
--- params: {prohibit_evil_variables => {variables => '$foo $bar'}}
--- input
my $foo = "I'm evil";
print $bar;

===
--- dscr: evil variables with brackets
--- failures: 2
--- params: {prohibit_evil_variables => {variables => '${^WIN32_SLOPPY_STAT} %{^_Fubar}'}}
--- input
${^WIN32_SLOPPY_STAT} and print "We are being sloppy\n";
our %{^_Fubar};

===
--- dscr: subscripted evil variables with brackets
--- failures: 1
--- params: {prohibit_evil_variables => {variables => '%{^_Fubar}'}}
--- input
print "The value of \${^_Fubar}{baz} is ", ${^_Fubar}{baz}, "\n";

===
--- dscr: No evil variables
--- failures: 0
--- params: {prohibit_evil_variables => {variables => '$[ $SIG{__DIE__}'}}
--- input
print 'Perl version is ', $], "\n";
local $SIG{__WARN__} = sub {print {STDERR} "Danger Will Robinson!\n"};

===
--- dscr: 2 evil variables, with pattern matching
--- failures: 2
--- params: {prohibit_evil_variables => {variables => '/\[/ /\bSIG\b/'}}
--- input
print 'First subscript is ', $[, "\n";
local $SIG{__DIE__} = sub {warn "I cannot die!"};

===
--- dscr: More evil variables, with mixed config
--- failures: 4
--- params: {prohibit_evil_variables => {variables => '$[ /\bSIG\b/ $^S'}}
--- input
## TODO failures: 5 is truth
print 'First subscript is ', $[, "\n";
local $SIG{__DIE__} = sub {warn "I cannot die!"};
print $^S ? 'Executing eval' : defined $^S ? 'Otherwise' : 'Parsing';
local $SIG{__WARN__} = sub {print {STDERR} "Danger, Will Robinson!\n";

===
--- dscr: Recognize use of elements of evil arrays and hashes
--- failures: 2
--- params: {prohibit_evil_variables => {variables => '%SIG @INC'}}
--- input
local $SIG{__DIE__} = sub {warn "I cannot die!"};
print '$INC[0] is ', $INC[0], "\n";

===
--- dscr: Regexes with modifiers
--- failures: 4
--- params: {prohibit_evil_variables => {variables => '/(?x: \b SIG \b )/ /(?i:\binc\b)/ /(?ix: acme )/'}}
--- input
local $SIG{__DIE__} = sub {warn "I cannot die!"};
print '$INC[0] is ', $INC[0], "\n";
print '$inc[0] is ', $inc[0], "\n";
my $Acme = 'For the discerning coyote';

===
--- dscr: More evil variables, with more pattern matching
--- failures: 4
--- params: {prohibit_evil_variables => {variables => '/foo|bar|baz/'}}
--- input
my $foo;
my $bar;
my $baz;
my $foonly;

===
--- dscr: Providing the description for variables, no regular expressions.
--- params: {prohibit_evil_variables => {variables => q'$[ {Found use of $[. Code for first index = 0 instead} $SIG{__DIE__} <Found use of $SIG{__DIE__}. Use END{} or override CORE::GLOBAL::die instead>'}}
--- failures: 2
--- input
print 'First subscript is ', $[, "\n";
local $SIG{__DIE__} = sub {warn "I cannot die!"};

===
--- dscr: Providing the description for variables, regular expressions.
--- failures: 2
--- params: {prohibit_evil_variables => {variables => q' /\bSIG\b/ {Found use of SIG. Do not use signals} /\bINC\b/ {Found use of INC. Do not manipulate @INC directly} '}}
--- input
local $SIG{__DIE__} = sub {warn "I cannot die!"};
print '$INC[0] is ', $INC[0], "\n";

===
--- dscr: Providing the description for variables, regular expressions with modifiers.
--- failures: 3
--- params: {prohibit_evil_variables => {variables => ' /(?x: \b SIG \b )/{We do not like signals.} /(?i:\binc\b)/[Do not fiddle with INC, no mater how it is capitalized] '}}
--- input
local $SIG{__DIE__} = sub {warn "I cannot die!"};
print '$INC[0] is ', $INC[0], "\n";
print '$inc[0] is ', $inc[0], "\n";

===
--- dscr: Providing the description for variables from file, no regular expressions.
--- failures: 3
--- params: {prohibit_evil_variables => {variables_file => 't/Policy/Variables/resources/variables-no-regular-expressions.txt'}}
--- input
# TODO truth: --- failures: 3
print 'First subscript is ', $[, "\n";
local $SIG{__DIE__} = sub {warn "I cannot die!"};
print $^S ? 'Executing eval' : defined $^S ? 'Otherwise' : 'Parsing';

===
--- dscr: Providing the description for variables from file, regular expressions.
--- failures: 3
--- params: {prohibit_evil_variables => {variables_file => 't/Policy/Variables/resources/variables-regular-expressions.txt'}}
--- input
# TODO truth: --- failures: 3
print 'First subscript is ', $[, "\n";
local $SIG{__DIE__} = sub {warn "I cannot die!"};
print $^S ? 'Executing eval' : defined $^S ? 'Otherwise' : 'Parsing';

