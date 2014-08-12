package Perl::Lint::Policy::ValuesAndExpressions::ProhibitMixedBooleanOperators;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Mixed high and low-precedence booleans',
    EXPL => [70],
};

use constant {
    ALPHABETICAL     => 1,
    NON_ALPHABETICAL => 2,
    INVALID          => 3,
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;

    my @context_for_each_depth;
    my $left_paren_num = 0;
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == SEMI_COLON) {
            if ($left_paren_num <= 0) {
                if (my $status = $context_for_each_depth[0]) {
                    if ($status == INVALID) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                }
                @context_for_each_depth = ();
            }
        }
        elsif ($token_type == LEFT_PAREN) {
            $left_paren_num++;
        }
        elsif ($token_type == RIGHT_PAREN) {
            if (my $status = splice @context_for_each_depth, $left_paren_num) {
                if ($status == INVALID) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }
            $left_paren_num--;
        }
        elsif (
            $token_type == AND ||
            $token_type == OR  ||
            $token_type == NOT
        ) {
            if (my $context = $context_for_each_depth[$left_paren_num]) {
                if ($context != NON_ALPHABETICAL) {
                    $context_for_each_depth[$left_paren_num] = INVALID;
                }
                next;
            }
            $context_for_each_depth[$left_paren_num] = NON_ALPHABETICAL;
        }
        elsif (
            $token_type ==  ALPHABET_AND ||
            $token_type ==  ALPHABET_OR  ||
            $token_type ==  ALPHABET_NOT ||
            $token_type ==  ALPHABET_XOR
        ) {
            if (my $context = $context_for_each_depth[$left_paren_num]) {
                if ($context != ALPHABETICAL) {
                    $context_for_each_depth[$left_paren_num] = INVALID;
                }
                next;
            }
            $context_for_each_depth[$left_paren_num] = ALPHABETICAL;
        }
    }

    return \@violations;
}

1;

