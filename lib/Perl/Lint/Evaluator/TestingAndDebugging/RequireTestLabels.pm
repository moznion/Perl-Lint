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
    my $is_loaded_test_more = 0;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token = $tokens->[$i];
        my $token_type = $token->{type};

        # for checking Test::More is loaded
        if ($token_type == USE_DECL || $token_type == REQUIRE_DECL) {
            $token = $tokens->[++$i];
            if (
                $token &&
                $token->{type} == NAMESPACE &&
                $token->{data} eq 'Test'
            ) {
                $token = $tokens->[$i+2];
                if (
                    $token->{type} == NAMESPACE &&
                    $token->{data} eq 'More'
                ) {
                    $is_loaded_test_more = 1;
                    $i += 2;
                    next;
                }
            }
            next;
        }
    }

    return \@violations if $is_loaded_test_more;
    return [];
}

1;

