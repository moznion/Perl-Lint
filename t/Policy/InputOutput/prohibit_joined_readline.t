use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::ProhibitJoinedReadline;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::ProhibitJoinedReadline';

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
$content = do {local $/ = undef; <>};
@content = <>;
$content = do {local $/ = undef; <$fh>};
@content = <$fh>;
$content = do {local $/ = undef; <STDIN>};
@content = <STDIN>;

===
--- dscr: basic failures
--- failures: 4
--- params:
--- input
$content = join '', <>;
$content = join('', <>);
$content = join $var, <>;
$content = join($var, <>);

===
--- dscr: ppi failures
--- failures: 8
--- params:
--- input
$content = join '', <$fh>;
$content = join '', <STDIN>;
$content = join('', <$fh>);
$content = join('', <STDIN>);
$content = join $var, <$fh>;
$content = join $var, <STDIN>;
$content = join($var, <$fh>);
$content = join($var, <STDIN>);

===
--- dscr: code coverage
--- failures: 0
--- params
--- input
$self->join($chain_link_1, $chain_link_2);

