use strict;
use warnings;
use Perl::Lint::Policy::ControlStructures::ProhibitLabelsWithSpecialBlockNames;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ControlStructures::ProhibitLabelsWithSpecialBlockNames';

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
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
BEGIN       { $x = 1; }
END         { $x = 1; }
CHECK       { $x = 1; }
INIT        { $x = 1; }
UNITCHECK   { $x = 1; }

===
--- dscr: Failure, cuddled colon
--- failures: 5
--- params:
--- input
BEGIN:      { $x = 1; }
END:        { $x = 1; }
CHECK:      { $x = 1; }
INIT:       { $x = 1; }
UNITCHECK:  { $x = 1; }

===
--- dscr: Failure, uncuddled colon
--- failures: 5
--- params:
--- input
BEGIN :     { $x = 1; }
END :       { $x = 1; }
CHECK :     { $x = 1; }
INIT :      { $x = 1; }
UNITCHECK : { $x = 1; }

