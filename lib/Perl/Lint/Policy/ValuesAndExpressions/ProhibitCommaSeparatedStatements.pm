package Perl::Lint::Policy::ValuesAndExpressions::ProhibitCommaSeparatedStatements;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Keywords;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Comma used to separate statements',
    EXPL => [68, 71],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $allow_last_statement_to_be_comma_separated_in_map_and_grep;
    if (my $this_policies_arg = $args->{prohibit_comma_separated_statements}) {
        $allow_last_statement_to_be_comma_separated_in_map_and_grep = $this_policies_arg->{allow_last_statement_to_be_comma_separated_in_map_and_grep};
    }

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == ASSIGN) {
            $token = $tokens->[++$i];
            $token_type = $token->{type};

            # if rvalues are surrounded by parans, theres are no problem
            if ($token_type != LEFT_PAREN && $token_type != LEFT_BRACE && $token_type != LEFT_BRACKET) {
                my $does_comma_exist = 0;

                ONE_LINE:
                for (; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    if ($token_type == COMMA) {
                        $does_comma_exist = 1;
                    }
                    elsif ($token_type == SEMI_COLON) {
                        last;
                    }
                    elsif ($token_type == KEY || $token_type == BUILTIN_FUNC) {
                        my $token_data = $token->{data};
                        if (
                            $token_type == BUILTIN_FUNC &&
                            is_perl_builtin_which_take_multiple_arguments($token_data)
                        ) {
                            my $is_map_or_grep = ($token_data eq 'map' || $token_data eq 'grep') ? 1 : 0;

                            my $next_token = $tokens->[$i+1];
                            my $next_token_type = $next_token->{type};
                            if ($next_token_type == LEFT_PAREN) {
                                my $left_paren_num = 1;
                                for ($i+=2; $token = $tokens->[$i]; $i++) {
                                    $token_type = $token->{type};
                                    if ($token_type == LEFT_PAREN) {
                                        $left_paren_num++;
                                    }
                                    elsif ($token_type == RIGHT_PAREN) {
                                        last if --$left_paren_num <= 0;
                                    }
                                }
                            }
                            else {
                                my $left_brace_num = 0;

                                if ($is_map_or_grep && !$allow_last_statement_to_be_comma_separated_in_map_and_grep) {
                                    for (; $token = $tokens->[$i]; $i++) {
                                        $token_type = $token->{type};

                                        if ($token_type == LEFT_BRACE) {
                                            $left_brace_num++;
                                        }
                                        elsif ($token_type == RIGHT_BRACE) {
                                            last if --$left_brace_num <= 0;
                                        }
                                        elsif ($token_type == COMMA) {
                                            my $next_token = $tokens->[$i+1];
                                            my $next_token_type = $next_token->{type};
                                            if ($next_token_type != KEY) {
                                                $does_comma_exist = 1;
                                            }
                                        }
                                    }
                                    $i++;
                                }

                                for (; $token = $tokens->[$i]; $i++) {
                                    $token_type = $token->{type};
                                    if ($token_type == SEMI_COLON) {
                                        last ONE_LINE;
                                    }
                                }
                            }
                        }

                        for ($i++; $token = $tokens->[$i]; $i++) {
                            $token_type = $token->{type};
                            if ($token_type == COMMA) {
                                my $next_token = $tokens->[$i+1];
                                my $next_token_type = $next_token->{type};
                                if ($next_token_type != KEY) {
                                    $does_comma_exist = 1;
                                }

                                last;
                            }
                            elsif ($token_type == SEMI_COLON) {
                                last ONE_LINE;
                            }
                        }
                    }
                }

                if ($does_comma_exist) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line}, # TODO
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }
            else {
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    if ($token_type == SEMI_COLON) {
                        last;
                    }
                }
            }
        }
        elsif ($token_type == FOR_STATEMENT) {
            my $next_token = $tokens->[$i+1];

            if ($next_token->{type} != LEFT_PAREN) {
                next;
            }

            my $left_paren_num = 1;
            my $does_comma_exist = 0;
            my $is_semi_colon_in_paren = 0; # XXX
            for ($i+=2; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};

                if ($token_type == LEFT_PAREN) {
                    $left_paren_num++;
                }
                elsif ($token_type == RIGHT_PAREN) {
                    if ($does_comma_exist && $is_semi_colon_in_paren) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line}, # TODO
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }

                    last if --$left_paren_num <= 0;
                }
                elsif ($token_type == COMMA) {
                    $does_comma_exist = 1;
                }
                elsif ($token_type == SEMI_COLON) {
                    if ($does_comma_exist) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line}, # TODO
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                    $is_semi_colon_in_paren = 1;
                    $does_comma_exist = 0;
                }
            }
        }
    }

    return \@violations;
}

1;

