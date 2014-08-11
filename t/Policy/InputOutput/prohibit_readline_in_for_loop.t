use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::ProhibitReadlineInForLoop;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::ProhibitReadlineInForLoop';

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
for my $foo (<FH>) {}
for $foo (<$fh>) {}
for (<>) {}
$_ for <FH>
$_ for <$fh>
$_ for <>

foreach my $foo (<FH>) {}
foreach $foo (<$fh>) {}
foreach (<>) {}
$_ foreach <FH>
$_ foreach <$fh>
$_ foreach <>

===
--- dscr: basic passes
--- failures: 0
--- params:
--- input
for my $foo (@lines) {}
while( my $foo = <> ){}
while( $foo = <> ){}
while( <> ){}

