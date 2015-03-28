use strict;
use warnings;
use Perl::Lint::Policy::Miscellanea::ProhibitUselessNoLint;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;
use feature qw/state/;
use Perl::Lint;
use File::Temp qw/tempfile/;

my $class_name = 'Miscellanea::ProhibitUselessNoLint';

filters {
    params => [qw/eval/],
};

sub _fetch_violations {
    my ($class, $input, $args) = @_;

    my ($fh, $filename) = tempfile(UNLINK => 1);
    print $fh $input;
    close $fh;

    state $linter;

    # to reuse instance
    if (
        !$linter || # init
        ($args && %$args) || # args are exists
        ($linter->{args} && %{$linter->{args}}) # previous instance has args
    ) {
        $linter = Perl::Lint->new($args);
    }

    $linter->{site_policies} = ["Perl::Lint::Policy::$class", 'Perl::Lint::Policy::RegularExpressions::RequireExtendedFormatting'];
    return $linter->lint($filename);
}

for my $block (blocks) {
    my $violations = _fetch_violations($class_name, $block->input, $block->params);
    is scalar @$violations, $block->failures, $block->dscr;
}

done_testing;

__DATA__

===
--- dscr: basic passes
--- failures: 0
--- params:
--- input
my $string =~ m{pattern.}; ## no lint
my $string =~ m{pattern.}; ## no lint (RequireExtendedFormatting)
my $string =~ m{pattern.}; ## no lint "RequireExtendedFormatting"
my $string =~ m{pattern.}; ## no lint 'RequireExtendedFormatting'
my $string =~ m{pattern.}; ## no lint qw(RequireExtendedFormatting)

===
--- dscr: basic failures
--- failures: 2
--- params:
--- input
my $foo = "bar";  ## no lint
my $foo = "bar";  ## no lint (RequireExtendedFormatting)

