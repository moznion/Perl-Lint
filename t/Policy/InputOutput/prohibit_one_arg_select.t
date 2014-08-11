use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::ProhibitOneArgSelect;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::ProhibitOneArgSelect';

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
--- dscr: 1 arg; variable w/parens
--- failures: 1
--- params:
--- input
select( $fh );

===
--- dscr: 1 arg; variable, as built-in
--- failures: 1
--- params:
--- input
select $fh;

===
--- dscr: 1 arg; fh, w/parens
--- failures: 1
--- params:
--- input
select( STDERR );

===
--- dscr: 1 arg; fh, as built-in
--- failures: 1
--- params:
--- input
select STDERR;

===
--- dscr: 4 args
--- failures: 0
--- params:
--- input
select( undef, undef, undef, 0.25 );

===
--- dscr: RT Bug #15653
--- failures: 0
--- params:
--- input
sub select { }

