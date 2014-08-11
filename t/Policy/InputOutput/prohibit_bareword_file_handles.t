use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::ProhibitBarewordFileHandles;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::ProhibitBarewordFileHandles';

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
--- dscr: standard filehandles are OK
--- failures: 0
--- params:
--- input
open(STDIN, '<', '/dev/null') or die;
open(STDOUT, '>', '/dev/null') or die;
open(STDERR, '>', '/dev/null') or die;

===
--- dscr: basic failures
--- failures: 5
--- params:
--- input
open FH, '>', $some_file;
open FH, '>', $some_file or die;
open(FH, '>', $some_file);
open(FH, '>', $some_file) or die;
open(STDERROR, '>', '/dev/null') or die;

===
--- dscr: basic passes
--- failures: 0
--- params:
--- input
open $fh, '>', $some_file;
open $fh, '>', $some_file or die;
open($fh, '>', $some_file);
open($fh, '>', $some_file) or die;

open my $fh, '>', $some_file;
open my $fh, '>', $some_file or die;
open(my $fh, '>', $some_file);
open(my $fh, '>', $some_file) or die;

$foo{open}; # not a function call
{open}; # zero args, for Devel::Cover

