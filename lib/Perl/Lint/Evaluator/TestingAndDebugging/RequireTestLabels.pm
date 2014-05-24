package Perl::Lint::Evaluator::TestingAndDebugging::RequireTestLabels;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";
use constant {
    test_more_functions => [qw/ok is isnt like unlike cmp_ok is_deeply pass fail/]
};

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    use Data::Dumper::Concise; warn Dumper($tokens); # TODO remove
    my @violations;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
    }

    return \@violations;
}

1;

