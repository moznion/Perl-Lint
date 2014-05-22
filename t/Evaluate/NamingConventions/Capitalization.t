#!perl

use strict;
use warnings;
use Perl::Lint::Evaluator::NamingConventions::Capitalization;
use t::Evaluate::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'NamingConventions::Capitalization';

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
--- dscr: Basic Passes
--- failures: 0
--- params: {}
--- input
my  $foo;
our $bar;
my($foo, $bar) = ("BLEH", "BLEH");
my @foo;
my %bar;
sub foo {}

my  $foo123;
my  $foo123bar;
sub foo123 {}
sub foo123bar {}

package This::SomeThing;
package This;
package This::Thing;
package Acme::12345;
package YYZ;
