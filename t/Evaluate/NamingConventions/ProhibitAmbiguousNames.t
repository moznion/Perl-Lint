#!perl

use strict;
use warnings;
use Perl::Lint::Evaluator::NamingConventions::ProhibitAmbiguousNames;
use t::Evaluate::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'NamingConventions::ProhibitAmbiguousNames';

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
--- dscr: Basic failures.
--- failures: 11
--- params: {}
--- input
my $left = 1;          # scalar
my @right = ('foo');   # array
our $no = undef;       # our
my %abstract;          # hash
local *main::contract; # pkg prefix on var
sub record {}          # sub
my ($second, $close);  # catch both of these
sub pkg::bases {}      # pkg prefix on sub
my ($last, $set);

===
--- dscr: Ambiguous word in compound name.
--- failures: 2
--- params: {}
--- input
my $last_record;
my $first_record;

===
--- dscr: Basic passes.
--- failures: 0
--- params: {}
--- input
for my $bases () {}
foreach my $bases () {}
print $main::contract;
some_func $main::contract;
my %hash = (left => 1, center => 'right');
sub no_left_turn {}
local $\; # for Devel::Cover; an example of a var declaration without \w
