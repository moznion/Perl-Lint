package Perl::Lint::Policy::ValuesAndExpressions::ProhibitVersionStrings;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Version string used',
    EXPL => 'Use a real number instead',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if (
            $token_type == USE_DECL  ||
            $token_type == USED_NAME ||
            $token_type == NAMESPACE ||
            $token_type == REQUIRE_DECL ||
            $token_type == REQUIRED_NAME
        ) {
            $token_type = $tokens->[$i+1]->{type};

            if ($token_type == DOUBLE) {
                $token_type = $tokens->[$i+2]->{type};
                if ($token_type == DOUBLE) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }
            elsif ($token_type == VERSION_STRING) {
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

    return \@violations;
}

1;

