use strict;
use warnings;
use Perl::Lint::Policy::Variables::ProhibitMatchVars;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Variables::ProhibitMatchVars';

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
--- dscr: Basic
--- failures: 9
--- params:
--- input
use English qw($PREMATCH);
use English qw($MATCH);
use English qw($POSTMATCH);
$`;
$&;
$';
$PREMATCH;
$MATCH;
$POSTMATCH;

===
--- dscr: English with multiple args
--- failures: 3
--- params:
--- input
use English qw($PREMATCH $MATCH $POSTMATCH);

===
--- dscr: Ignore case handled by RequireNoMatchVarsWithUseEnglish
--- failures: 0
--- params:
--- input
use English;

===
--- dscr: no_match_vars
--- failures: 0
--- params:
--- input
use English qw(-no_match_vars);
use English qw($EVAL_ERROR);

