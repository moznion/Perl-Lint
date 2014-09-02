use strict;
use warnings;
use Perl::Lint::Policy::RegularExpressions::ProhibitSingleCharAlternation;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'RegularExpressions::ProhibitSingleCharAlternation';

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
m/\A [adiqrwx] \z/xms;
m/\A (?: qq | qr | qx | [qsy] | tr ) \z/xms;
m/\A (?: q[qrx] | [qsy] | tr ) \z/xms;

m/\A (?: a ) \z/xms;   # bad form, but not a violation of this policy
m/\A (?: [a] ) \z/xms; # bad form, but not a violation of this policy

===
--- dscr: warnings reported by users (App::Ack)
--- failures: 1
--- params:
--- input
return ('shell',TEXT)  if $header =~ /\b(?:ba|c|k|z)?sh\b/;

===
--- dscr: metacharacters
--- failures: 0
--- params:
--- input
m/(?: ^ | . | \d | $ )/xms;

===
--- dscr: allowed to have one single character alternation
--- failures: 0
--- params:
--- input
m/\A (?: a | do | in | queue | rue | woe | xray ) \z/xms;
return 1 if $file =~ m/ [.] (?: p (?: l x? | m ) | t | PL ) \z /xms;

===
--- dscr: basic failures
--- failures: 2
--- params:
--- input
m/\A (?: a | d | i | q | r | w | x ) \z/xms;
m/\A (?: qq| qr | qx | q | s | y | tr ) \z/xms;

# TODO
# ===
# --- dscr: failing regexp with syntax error
# --- failures: 0
# --- params:
# --- input
# m/\A (?: a | d | i | q | r | w | x ) ( \z/xms;
#
