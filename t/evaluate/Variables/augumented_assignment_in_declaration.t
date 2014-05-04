#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use Perl::Lint;
use Perl::Lint::Evaluator::Variables::AugmentedAssignmentInDeclaration;

use Test::More;

my $resource_dir = "$FindBin::Bin/resources/augumented_assignment_in_declaration";

subtest 'Normal assignment ok' => sub {
    my $file       = "$resource_dir/normal_assignment.pl";
    my $tokens     = Perl::Lint::_tokenize($file);
    my $violations = Perl::Lint::Evaluator::Variables::AugmentedAssignmentInDeclaration->evaluate($file, $tokens);

    is_deeply $violations, [];
};

subtest 'Normal assignment with operators ok' => sub {
    my $file       = "$resource_dir/normal_assignment_with_operators.pl";
    my $tokens     = Perl::Lint::_tokenize($file);
    my $violations = Perl::Lint::Evaluator::Variables::AugmentedAssignmentInDeclaration->evaluate($file, $tokens);

    is_deeply $violations, [];
};

subtest 'real life regression' => sub {
    my $file       = "$resource_dir/real_life_regression.pl";
    my $tokens     = Perl::Lint::_tokenize($file);
    my $violations = Perl::Lint::Evaluator::Variables::AugmentedAssignmentInDeclaration->evaluate($file, $tokens);

    is_deeply $violations, [];
};

subtest 'scalar augumented assignment' => sub {
    my $file       = "$resource_dir/scalar_augumented_assignment.pl";
    my $tokens     = Perl::Lint::_tokenize($file);
    my $violations = Perl::Lint::Evaluator::Variables::AugmentedAssignmentInDeclaration->evaluate($file, $tokens);

    is scalar @$violations, 52;
    # TODO
};

subtest 'real life examples' => sub {
    my $file       = "$resource_dir/real_life_fail_example.pl";
    my $tokens     = Perl::Lint::_tokenize($file);
    my $violations = Perl::Lint::Evaluator::Variables::AugmentedAssignmentInDeclaration->evaluate($file, $tokens);

    is scalar @$violations, 8;
};

done_testing;

