package Perl::Lint::Policy::BuiltinFunctions::ProhibitStringySplit;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'String delimiter used with "split"',
    EXPL => 'Express it as a regex instead',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && $token_data eq 'split') {
            $token = $tokens->[++$i];

            if ($token->{type} == LEFT_PAREN) {
                $token = $tokens->[++$i];
            }

            $token_type = $token->{type};
            $token_data = $token->{data};

            if (
                ($token_type == STRING || $token_type == RAW_STRING) &&
                $token_data ne ' '
            ) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
            elsif ($token_type == REG_QUOTE || $token_type == REG_DOUBLE_QUOTE) {
                $i += 2;
                if ($tokens->[$i]->{data} ne ' ') {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }
        }
    }

    return \@violations;
}

1;

