#!perl

use strict;
use warnings;
use utf8;
use Perl::Lint;
use Perl::Lint::Policy::Variables::ProhibitConditionalDeclarations;
use t::Policy::Util qw/fetch_violations/;
use Test::More;

my $class_name = 'Variables::ProhibitConditionalDeclarations';

subtest 'with if at post-position' => sub {
    my $src = <<'...';
my $foo = 1 if $bar;
our $foo = 1 if $bar;
my ($foo, $baz) = @list if $bar;
our ($foo, $baz) = 1 if $bar;
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 4;
    # TODO
};

subtest 'with unless at post-position' => sub {
    my $src = <<'...';
my $foo = 1 unless $bar;
our $foo = 1 unless $bar;
my ($foo, $baz) = @list unless $bar;
our ($foo, $baz) = 1 unless $bar;
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 4;
};

subtest 'with while at post-position' => sub {
    my $src = <<'...';
my $foo = 1 while $bar;
our $foo = 1 while $bar;
my ($foo, $baz) = @list while $bar;
our ($foo, $baz) = 1 while $bar;
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 4;
};

subtest 'with for at post-position' => sub {
    my $src = <<'...';
my $foo = 1 for @bar;
our $foo = 1 for @bar;
my ($foo, $baz) = @list for @bar;
our ($foo, $baz) = 1 for @bar;
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 4;
};

subtest 'with foreach at post-position' => sub {
    my $src = <<'...';
my $foo = 1 foreach @bar;
our $foo = 1 foreach @bar;
my ($foo, $baz) = @list foreach @bar;
our ($foo, $baz) = 1 foreach @bar;
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 4;
};

subtest 'passing cases' => sub {
    my $src = <<'...';
for my $foo (@list) { do_something() }
foreach my $foo (@list) { do_something() }
while (my $foo $condition) { do_something() }
until (my @foo = ($condition)) {
    {
        method => do_something(),
    }
}
unless (my $foo = $condition) { do_something() }
if (my $foo = $condition) { do_something() }
# these are terrible uses of "if" but do not violate the policy
my $foo = $hash{if};
my $foo = $obj->if();
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

subtest 'local is exempt' => sub {
    my $src = <<'...';
local $foo = $bar if $baz;
local ($foo) = $bar if $baz;
local $foo = $bar unless $baz;
local ($foo) = $bar unless $baz;
local $foo = $bar until $baz;
local ($foo) = $bar until $baz;
local ($foo, $bar) = 1 foreach @baz;
local ($foo, $bar) = 1 for @baz;
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

done_testing;

