package Perl::Lint::Evaluator::BuiltinFunctions::RequireGlobFunction;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == HANDLE_DELIM) {
            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};

                if ($token_type == MUL) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                    };
                }
                elsif ($token_type == GREATER) {
                    last;
                }
            }
        }
    }

    return \@violations;
}

1;

