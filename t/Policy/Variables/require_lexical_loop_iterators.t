use strict;
use warnings;
use Perl::Lint::Policy::Variables::RequireLexicalLoopIterators;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Variables::RequireLexicalLoopIterators';

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
--- failures: 2
--- params:
--- input
for $foo ( @list ) {}
foreach $foo ( @list ) {}

===
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
for my $foo ( @list ) {}
foreach my $foo ( @list ) {}

===
--- dscr: Passing lexicals on loops with labels.
--- failures: 0
--- params:
--- input
LABEL: for my $foo ( @list ) {}
ANOTHER_LABEL: foreach my $foo ( @list ) {}

BING: for ( @list ) {}
BANG: foreach ( @list ) {}

===
--- dscr: Failing lexicals on loops with labels.
--- failures: 2
--- params:
--- input
LABEL: for $foo ( @list ) {}
ANOTHER_LABEL: foreach $foo ( @list ) {}

===
--- dscr: Implicit $_ passes
--- failures: 0
--- params:
--- input
for ( @list ) {}
foreach ( @list ) {}

===
--- dscr: Other compounds
--- failures: 0
--- params:
--- input
for ( $i=0; $i<10; $i++ ) {}
while ( $condition ) {}
until ( $condition ) {}

===
--- dscr: Ignore really, really old Perls. RT #67760
--- failures: 0
--- params:
--- input
require 5.003;

foreach $foo ( @list ) {
    bar( $foo );
}

