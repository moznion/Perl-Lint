package Perl::Lint::Policy::BuiltinFunctions::ProhibitBooleanGrep;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => '"grep" used in boolean context',
    EXPL => [71, 72],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    my $is_grep_called = 0;
    my $is_in_boolean_context = 0;
    my $is_in_numeric_comparison_context = 0;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if (
            $token_type == IF_STATEMENT     ||
            $token_type == UNLESS_STATEMENT ||
            $token_type == WHILE_STATEMENT  ||
            $token_type == UNTIL_STATEMENT
        ) {
            $token = $tokens->[++$i];
            $token_type = $token->{type};
            if ($token_type == LEFT_PAREN) {
                my $is_grep_called = 0;
                my $is_in_numeric_comparison_context = 0;

                my $left_paren_num = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == EQUAL_EQUAL) {
                        $is_in_numeric_comparison_context = 1;
                    }
                    elsif ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        if (--$left_paren_num <= 0) {
                            if ($is_grep_called && !$is_in_numeric_comparison_context) {
                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
                                    description => DESC,
                                    explanation => EXPL,
                                    policy => __PACKAGE__,
                                };
                            }
                            last;
                        }
                    }
                    elsif ($token_type == BUILTIN_FUNC && $token->{data} eq 'grep') {
                        $is_grep_called = 1;
                    }
                }
            }
            elsif ($token_type == BUILTIN_FUNC && $token->{data} eq 'grep') {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }

            next;
        }

        if ($token_type == BUILTIN_FUNC && $token->{data} eq 'grep') {
            $is_grep_called = 1;
        }

        if (
            $token_type == OR  ||
            $token_type == AND ||
            $token_type == ALPHABET_OR ||
            $token_type == ALPHABET_AND
        ) {
            $is_in_boolean_context = 1;
        }

        if ($token_type == EQUAL_EQUAL) {
            $is_in_numeric_comparison_context = 1;
        }

        if ($token_type == SEMI_COLON) {
            if ($is_grep_called && $is_in_boolean_context && !$is_in_numeric_comparison_context) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
            $is_grep_called = 0;
            $is_in_boolean_context = 0;
            $is_in_numeric_comparison_context = 0;
            next;
        }
    }

    return \@violations;
}

1;

