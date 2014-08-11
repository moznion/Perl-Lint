#!perl

use strict;
use warnings;
use Perl::Lint::Policy::ClassHierarchies::ProhibitOneArgBless;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ClassHierarchies::ProhibitOneArgBless';

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
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
my $self = bless {}, 'foo';
my $self = bless( {}, 'foo' );
my $self = bless [], 'foo';
my $self = bless( [], 'foo' );
my $self = bless {} => 'foo';

$baz{bless}; # not a function call
$bar->bless('foo'); # method call

$data{"attachment_$index"} = bless([ $files->[$i] ], "Attachment");

===
--- dscr: Basic failure
--- failures: 4
--- params:
--- input
my $self = bless {};
my $self = bless [];

my $self = bless( {} );
my $self = bless( [] );

