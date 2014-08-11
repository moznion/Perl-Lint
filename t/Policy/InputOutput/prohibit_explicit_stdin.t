use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::ProhibitExplicitStdin;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::ProhibitExplicitStdin';

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
$foo = 'STDIN';
my $STDIN = 1;
close STDIN;
while (<>) {
  print;
}
while (<FOO>) {
  print;
}
while (<$fh>) {
  print;
}

===
--- dscr: basic failures
--- failures: 3
--- params:
--- input
$answer = <STDIN>;
while (<STDIN>) {
  print;
}
if (<STDIN> =~ /y/) {
  remove 'tmp.txt';
}

===
--- dscr: ppi failures
--- failures: 4
--- params:
--- input
$content = join '', <STDIN>;
$content = join('', <STDIN>);
$content = join $var, <STDIN>;
$content = join($var, <STDIN>);

