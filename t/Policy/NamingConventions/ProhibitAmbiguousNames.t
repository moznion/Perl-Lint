#!perl

use strict;
use warnings;
use Perl::Lint::Policy::NamingConventions::ProhibitAmbiguousNames;
use t::Policy::Util qw/fetch_violations/;
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

===
--- dscr: Ambiguous name on rhs.
--- failures: 0
--- params: {}
--- input
my ($foo) = ($left);

===
--- dscr: Ambiguous, but exempt by convention
--- failures: 0
--- params: {}
--- input
no warnings;
close $fh;

===
--- dscr: Custom null configuration
--- failures: 0
--- params: { prohibit_ambiguous_names => { forbid => q{} } }
--- input
my $left;
my $close;
END_PERL

===
--- dscr: Custom configuration: "foo bar baz quux"
--- failures: 2
--- params: { prohibit_ambiguous_names => { forbid => 'foo bar baz quux' } }
--- input
my $left;
my $close;
my $foo;
my $bar;

===
--- dscr: Custom configuration: "foo bar baz quux"
--- failures: 4
--- params: { prohibit_ambiguous_names => { forbid => 'foo bar left close' } }
--- input
my $left;
my $close;
my $foo;
my $bar;

#%config = ( forbid => join q{ }, qw(foo bar baz quux), @default );

===
--- dscr: Custom null configuration
--- params: { prohibit_ambiguous_names => { forbid => undef } }
--- failures: 2
--- input
my $left;
my $close;

