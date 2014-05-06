#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use Perl::Lint;
use Perl::Lint::Evaluator::Variables::ConditionalDeclarations;
use t::Evaluate::Util qw/fetch_violations/;
use Test::More;

my $resource_dir = "$FindBin::Bin/resources/conditional_declarations";
my $class_name   = 'ConditionalDeclarations';

subtest 'with if at post-position' => sub {
    my $file       = "$resource_dir/if_at_post_position.pl";
    my $violations = fetch_violations($file, $class_name);

    is scalar @$violations, 4;
    # TODO
};

subtest 'with unless at post-position' => sub {
    my $file       = "$resource_dir/unless_at_post_position.pl";
    my $violations = fetch_violations($file, $class_name);

    is scalar @$violations, 4;
};

subtest 'with while at post-position' => sub {
    my $file       = "$resource_dir/while_at_post_position.pl";
    my $violations = fetch_violations($file, $class_name);

    is scalar @$violations, 4;
};

subtest 'with for at post-position' => sub {
    my $file       = "$resource_dir/for_at_post_position.pl";
    my $violations = fetch_violations($file, $class_name);

    is scalar @$violations, 4;
};

subtest 'with foreach at post-position' => sub {
    my $file       = "$resource_dir/foreach_at_post_position.pl";
    my $violations = fetch_violations($file, $class_name);

    is scalar @$violations, 4;
};

subtest 'passing cases' => sub {
    my $file       = "$resource_dir/passing_cases.pl";
    my $violations = fetch_violations($file, $class_name);

    is scalar @$violations, 0;
};

subtest 'local is exempt' => sub {
    my $file       = "$resource_dir/local.pl";
    my $violations = fetch_violations($file, $class_name);

    is scalar @$violations, 0;
};

done_testing;

