package Perl::Lint::Policy::ErrorHandling::RequireCheckingReturnValueOfEval;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Return value of eval not tested.',
    EXPL => q{You can't depend upon the value of $@/$EVAL_ERROR to tell whether an eval failed.},
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $token_num  = scalar @$tokens;
    my $assigned   = 0;
    my $is_in_grep = 0;
    my $left_paren_num   = 0;
    my $left_brace_num   = 0;
    my $left_bracket_num = 0;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token = $tokens->[$i];
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == ASSIGN) {
            $assigned = 1;
        }
        elsif ($token_type == COMMA) {
            if (
                $left_paren_num   <= 0 &&
                $left_brace_num   <= 0 &&
                $left_bracket_num <= 0
            ) {
                $assigned = 0;
            }
        }
        elsif ($token_type == LEFT_PAREN) {
            $left_paren_num++;
        }
        elsif ($token_type == LEFT_BRACE) {
            $left_brace_num++;
        }
        elsif ($token_type == LEFT_BRACKET) {
            $left_bracket_num++;
        }
        elsif ($token_type == RIGHT_PAREN) {
            $left_paren_num--;
        }
        elsif ($token_type == RIGHT_BRACE) {
            $left_brace_num--;
        }
        elsif ($token_type == RIGHT_BRACKET) {
            $left_bracket_num--;
        }
        elsif ($token_type == BUILTIN_FUNC && $token_data eq 'grep') {
            $is_in_grep = 1;
        }
        elsif (
            !$assigned   &&
            !$is_in_grep &&
            $token_type == BUILTIN_FUNC &&
            $token_data eq 'eval'
        ) {
            my $is_ternary = 0;
            my $is_proper  = 0;
            my $left_brace_num = 0;

            # XXX not good cuz run twice
            for (my $j = $i + 1; $j < $token_num; $j++) {
                my $token = $tokens->[$j];
                my $token_type = $token->{type};

                if ($token_type == LEFT_BRACE) {
                    $left_brace_num++;
                }
                elsif ($token_type == RIGHT_BRACE) {
                    $left_brace_num--;
                }
                elsif ($token_type == THREE_TERM_OP) {
                    $is_ternary = 1;
                }
                elsif (
                    $left_brace_num <= 0 &&
                    (
                        $token_type == AND ||
                        $token_type == OR  ||
                        $token_type == ALPHABET_AND ||
                        $token_type == ALPHABET_OR
                    )
                ) {
                    $is_proper = 1;
                }
                elsif (
                    $left_brace_num <= 0 &&
                    $token_type == SEMI_COLON ||
                    !$tokens->[$j+1]
                ) {
                    last;
                }
            }

            if (!$is_ternary && !$is_proper) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
        elsif ($token_type == IF_STATEMENT) {
            my $left_paren_num   = 0;
            my $left_paren_found = 0;
            my $exists_eval = 0;
            my $exists_eval_global = 0;
            my $exists_comma = 0;
            my $last_token = {type => -1, data => ''};
            for ($i++; $i < $token_num; $i++) {
                my $token = $tokens->[$i];
                my $token_type = $token->{type};

                if ($token_type == BUILTIN_FUNC && $token->{data} eq 'eval') {
                    $exists_eval = 1;
                    $exists_eval_global = 1;
                }
                elsif ($token_type == COMMA) {
                    $exists_comma = 1;

                    my $next_token = $tokens->[$i + 1];
                    my $next_token_type = $next_token->{type};
                    if (
                        $next_token_type != COMMA &&
                        $next_token_type != RIGHT_PAREN
                    ) {
                        $last_token = $next_token;
                    }
                }
                elsif ($token_type == LEFT_PAREN) {
                    $left_paren_num++;
                    $left_paren_found++;
                    $exists_eval  = 0;
                    $exists_comma = 0;
                }
                elsif ($token_type == RIGHT_PAREN) {
                    if (
                        $last_token->{type} != BUILTIN_FUNC &&
                        $last_token->{data} ne 'eval' &&
                        ($exists_eval_global || $exists_eval) && $exists_comma
                    ) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                    $left_paren_num--;
                    $exists_eval  = 0;
                    $exists_comma = 0;
                }

                if (
                    ($left_paren_num <= 0 && $left_paren_found) ||
                    $token == SEMI_COLON ||
                    !$tokens->[$i+1]
                ) {
                    last;
                }
            }
        }
        elsif (
            $token_type == FOREACH_STATEMENT ||
            $token_type == WHILE_STATEMENT
        ) {
            my $left_paren_num   = 0;
            my $left_paren_found = 0;
            for ($i++; $i < $token_num; $i++) {
                my $token = $tokens->[$i];
                my $token_type = $token->{type};

                if ($token_type == LEFT_PAREN) {
                    $left_paren_num++;
                    $left_paren_found++;
                }
                elsif ($token_type == RIGHT_PAREN) {
                    $left_paren_num--;
                }

                if (
                    ($left_paren_num <= 0 && $left_paren_found) ||
                    $token == SEMI_COLON ||
                    !$tokens->[$i+1]
                ) {
                    last;
                }
            }
        }
        elsif ($token_type == FOR_STATEMENT) {
            my $left_paren_num   = 0;
            my $left_paren_found = 0;
            my $assigned         = 0;
            my $block            = 1;
            for ($i++; $i < $token_num; $i++) {
                my $token = $tokens->[$i];
                my $token_type = $token->{type};

                if ($token_type == ASSIGN) {
                    $assigned = 1;
                }
                elsif ($token_type == LEFT_PAREN) {
                    $left_paren_num++;
                    $left_paren_found++;
                }
                elsif ($token_type == RIGHT_PAREN) {
                    $left_paren_num--;
                }
                elsif ($token_type == SEMI_COLON) {
                    $block++;
                    $assigned = 0;
                }
                elsif (
                    !$assigned &&
                    $block & 1 &&
                    $token_type == BUILTIN_FUNC &&
                    $token->{data} eq 'eval'
                ) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }

                if ($left_paren_num <= 0 && $left_paren_found) {
                    last;
                }
            }
        }
        elsif ($token_type == SEMI_COLON || !$tokens->[$i+1]) {
            $assigned = 0;
            $is_in_grep = 0;
        }
    }
    return \@violations;
}

1;

