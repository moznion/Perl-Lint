use strict;
use warnings;
use Perl::Lint::Policy::Variables::ProhibitReusedNames;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Variables::ProhibitReusedNames';

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
--- dscr: Simple block
--- failures: 2
--- params:
--- input
my $x;
{
    my $x;
}

sub foo {
    my $i;
    {
        my $i;
    }
}

===
--- dscr: Array
--- failures: 1
--- params:
--- input
my @x;
{
    my @x;
}

===
--- dscr: Hash
--- failures: 1
--- params:
--- input
my %x;
{
    my %x;
}

===
--- dscr: Outer bleeds into sub
--- failures: 3
--- params:
--- input
my $x;
{
    my $x;
}

sub foo {
    my $x;
    {
        my $x;
    }
}

===
--- dscr: Reversed scope
--- failures: 0
--- params:
--- input
{
    my $x;
}
my $x;

sub foo {
    {
        my $i;
    }
    my $i;
}

===
--- dscr: Our
--- failures: 2
--- params:
--- input
our $x;
{
    our $x;
}

sub foo {
    our $i;
    {
        our $i;
    }
}

===
--- dscr: Our vs. my
--- failures: 2
--- params:
--- input
our $x;
{
    my $x;
}

sub foo {
    our $i;
    {
        my $i;
    }
}

===
--- dscr: Same scope
--- failures: 2
--- params:
--- input
my $x;
my $x;

sub foo {
    my $i;
    my $i;
}

===
--- dscr: Conditional block
--- failures: 2
--- params:
--- input
my $x;
if (1) {
    my $x;
}

sub foo {
    my $i;
    if (1) {
        my $i;
    }
}

===
--- dscr: For loop
--- failures: 2
--- params:
--- input
my $x;
for my $y (0..10) {
    my $x;
}

sub foo {
    my $i;
    for my $z (0..10) {
        my $i;
    }
}

===
--- dscr: While loop
--- failures: 2
--- params:
--- input
my $x;
while (1) {
    my $x;
}

sub foo {
    my $i;
    while (1) {
        my $i;
    }
}

===
--- dscr: Deep block
--- failures: 2
--- params:
--- input
my $x;
for (0..5) {
    while (1) {
        if (foo()) {
            {
                my $x;
            }
        }
    }
}

sub foo {
    my $i;
    for (0..5) {
        while (1) {
            if (foo()) {
                {
                    my $i;
                }
            }
        }
    }
}

===
--- dscr: Other "my" syntax
--- failures: 4
--- params:
--- input
my $x;
{
    my ($x, $y, @z);
    {
        my ($x, $y, @z, $w);
        {
            my (@w);
        }
    }
}

===
--- dscr: Empty "my" (which is invalid Perl syntax, but supported)
--- failures: 0
--- params:
--- input
my $x;
{
    my ();
}

===
--- dscr: $self - RT #42767
--- failures: 0
--- params:
--- input
my $self;
{
    my $self;
}

===
--- dscr: $class - RT #42767
--- failures: 0
--- params:
--- input
my $class;
{
    my $class;
}

===
--- dscr: allow
--- failures: 0
--- params: {prohibit_reused_names => {allow => '$foobie'}}
--- input
my $foobie;
{
    my $foobie;
}

===
--- dscr: our with multiple packages - RT #43754
--- failures: 0
--- params:
--- input
## TODO We don't handle multiple packages in general, let alone in this policy.
package Foo;
our @ISA;
package Bar;
our @ISA;

