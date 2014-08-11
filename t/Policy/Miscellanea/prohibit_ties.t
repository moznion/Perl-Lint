use strict;
use warnings;
use Perl::Lint::Policy::Miscellanea::ProhibitTies;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Miscellanea::ProhibitTies';

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
--- dscr: basic failures
--- failures: 12
--- params:
--- input
tie $scalar, 'Some::Class';
tie @array, 'Some::Class';
tie %hash, 'Some::Class';

tie ($scalar, 'Some::Class');
tie (@array, 'Some::Class');
tie (%hash, 'Some::Class');

tie $scalar, 'Some::Class', @args;
tie @array, 'Some::Class', @args;
tie %hash, 'Some::Class' @args;

tie ($scalar, 'Some::Class', @args);
tie (@array, 'Some::Class', @args);
tie (%hash, 'Some::Class', @args);

===
--- dscr: basic passes
--- failures: 0
--- params:
--- input
$hash{tie} = 'foo';
%hash = ( tie => 'knot' );
$object->tie();

