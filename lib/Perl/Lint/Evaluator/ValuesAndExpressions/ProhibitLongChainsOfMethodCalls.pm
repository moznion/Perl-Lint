package Perl::Lint::Evaluator::ValuesAndExpressions::ProhibitLongChainsOfMethodCalls;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use parent "Perl::Lint::Evaluator";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $max_chain_length = $args->{prohibit_long_chains_of_method_calls}->{max_chain_length} || 3;

    my @violations;
    for (my $i = 0, my $token_type, my $num_of_chain = 0; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == POINTER) {
            my $next_token = $tokens->[$i+1];
            my $next_token_type = $next_token->{type};
            if ($next_token_type == LEFT_BRACE || $next_token_type == LEFT_BRACKET) {
                # array and hash ref chains. They should be ignored.
                next;
            }

            $num_of_chain++;
        }
        elsif ($token_type == SEMI_COLON || $token->{kind} == KIND_STMT) {
            if ($num_of_chain > $max_chain_length) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                };
            }
            $num_of_chain = 0;
        }
    }

    return \@violations;
}

1;

