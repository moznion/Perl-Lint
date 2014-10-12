package Perl::Lint::Policy::ValuesAndExpressions::ProhibitMagicNumbers;
use strict;
use warnings;
no warnings qw/numeric/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my %allowed_values = (
        0 => 1,
        1 => 1,
        2 => 1,
    );

    my %allowed_types = (
        Int   => 1,
        Float => 1,
    );

    my %constant_creator_subroutines = (
        plan     => 1,
        Readonly => 1,
        const    => 1,
    );

    my $allow_to_the_right_of_a_fat_comma = 1;
    if (my $this_policies_arg = $args->{prohibit_magic_numbers}) {
        $allow_to_the_right_of_a_fat_comma = $this_policies_arg->{allow_to_the_right_of_a_fat_comma} // 1;

        my $allowed_values = $this_policies_arg->{allowed_values};
        if (defined $allowed_values) {
            delete $allowed_values{2};
            for my $allowed_value (split /\s+/, $allowed_values) {
                my ($begin, $end) = split /[.][.]/, $allowed_value;
                if (defined $begin && defined $end) {
                    if (my ($delta) = $end =~ /:by\((.+)\)\z/) {
                        for (my $num = $begin; $num <= $end; $num += $delta) {
                            $allowed_values{$num} = 1;
                        }
                    }
                    else {
                        my $delta = 1;
                        for (my $num = $begin; $num <= $end; $num += $delta) {
                            $allowed_values{$num} = 1;
                        }
                    }
                }
                else {
                    $allowed_values{$allowed_value} = 1;
                }
            }
        }

        my $allowed_types = $this_policies_arg->{allowed_types};
        if (defined $allowed_types) {
            delete $allowed_types{Float};
            for my $allowed_type (split /\s+/, $allowed_types) {
                $allowed_types{$allowed_type} = 1;
            }
        }

        my $constant_creator_subroutines = $this_policies_arg->{constant_creator_subroutines};
        if (defined $constant_creator_subroutines) {
            for my $sub (split /\s+/, $constant_creator_subroutines) {
                $constant_creator_subroutines{$sub} = 1;
            }
        }
    }

    my @violations;
    my $is_in_constant_ctx = 0;
    my @invalid_tokens;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        @invalid_tokens = ();

        $token_type = $token->{type};
        $token_data = $token->{data};

        if (
            $token_type == USE_DECL     ||
            $token_type == REQUIRE_DECL ||
            ($token_type == KEY && $constant_creator_subroutines{$token_data})
        ) {
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == SEMI_COLON) {
                    last;
                }
            }
            next;
        }

        if ($token_type == NAMESPACE && $token_data eq 'Readonly') {
            $token = $tokens->[++$i] or last;
            if ($token->{type} == NAMESPACE_RESOLVER) {
                $token = $tokens->[++$i] or last;
                $token_data = $token->{data};
                if (
                    $token->{type} == NAMESPACE &&
                    ($token_data eq 'Scalar' || $token_data eq 'Array')
                ) {
                    for ($i++; $token = $tokens->[$i]; $i++) {
                        $token_type = $token->{type};
                        if ($token_type == SEMI_COLON) {
                            last;
                        }
                    }
                    next;
                }
                $is_in_constant_ctx = 1;
            }
        }

        if (
            ($token_type == VAR || $token_type == GLOBAL_VAR) &&
            $token_data eq '$VERSION'
        ) {
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == ASSIGN || $token_type == SEMI_COLON) {
                    last;
                }
            }
            next;
        }

        if (
            $token_type == ASSIGN ||
            (!$allow_to_the_right_of_a_fat_comma && $token_type == ARROW)
        ) {
            $token = $tokens->[++$i] or last;
            $token_type = $token->{type};
            $token_data = $token->{data};

            if ($token_type == DOUBLE) {
                if ($allowed_types{Float} && $allowed_values{$token_data+0}) { # `+0` to convert to number
                    my $next_token = $tokens->[$i+1];
                    if ($next_token && $next_token->{type} == DOUBLE) {
                        push @invalid_tokens, $next_token;
                    }
                }
                elsif (!$allowed_values{all_integers} || $token_data !~ /[.]0+\z/) {
                    push @invalid_tokens, $token;
                }
            }
            elsif ($token_type == INT) {
                if (my ($base_type) = $token_data =~ /\A[0-9]([b0xe]).+\z/) { # XXX
                    if ($1 eq 'b') {
                        if (!$allowed_types{Binary}) {
                            push @invalid_tokens, $token;
                            goto JUDGEMENT;
                        }
                    }
                    elsif ($1 eq '0') {
                        if (!$allowed_types{Octal}) {
                            push @invalid_tokens, $token;
                            goto JUDGEMENT;
                        }
                    }
                    elsif ($1 eq 'x') {
                        if (!$allowed_types{Hex}) {
                            push @invalid_tokens, $token;
                            goto JUDGEMENT;
                        }
                    }
                    elsif ($1 eq 'e') {
                        if (!$allowed_types{Exp}) {
                            push @invalid_tokens, $token;
                            goto JUDGEMENT;
                        }
                    }
                }

                if (!$allowed_types{Int}) {
                    push @invalid_tokens, $token;
                }
                elsif (!$allowed_values{all_integers} && !$allowed_values{$token_data+0}) { # `+0` to convert to number
                    push @invalid_tokens, $token;
                }
            }
            elsif ($token_type == LEFT_PAREN) {
                my $lpnum = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    $token_data = $token->{data};

                    if ($token_type == LEFT_PAREN) {
                        $lpnum++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        last if --$lpnum <= 0;
                    }

                    # XXX ugly!!!
                    elsif ($token_type == DOUBLE) {
                        if ($allowed_types{Float} && $allowed_values{$token_data+0}) { # `+0` to convert to number
                            my $next_token = $tokens->[$i+1];
                            if ($next_token && $next_token->{type} == DOUBLE) {
                                push @invalid_tokens, $next_token;
                            }
                        }
                        else {
                            push @invalid_tokens, $token;
                        }
                    }
                    elsif ($token_type == INT) {
                        if (my ($base_type) = $token_data =~ /\A[0-9]([b0xe]).+\z/) { # XXX
                            if ($1 eq 'b') {
                                if (!$allowed_types{Binary}) {
                                    push @invalid_tokens, $token;
                                    goto JUDGEMENT;
                                }
                            }
                            elsif ($1 eq '0') {
                                if (!$allowed_types{Octal}) {
                                    push @invalid_tokens, $token;
                                    goto JUDGEMENT;
                                }
                            }
                            elsif ($1 eq 'x') {
                                if (!$allowed_types{Hex}) {
                                    push @invalid_tokens, $token;
                                    goto JUDGEMENT;
                                }
                            }
                            elsif ($1 eq 'e') {
                                if (!$allowed_types{Exp}) {
                                    push @invalid_tokens, $token;
                                    goto JUDGEMENT;
                                }
                            }
                        }

                        if (!$allowed_types{Int}) {
                            push @invalid_tokens, $token;
                        }
                        elsif (!$allowed_values{$token_data+0}) { # `+0` to convert to number
                            push @invalid_tokens, $token;
                        }
                    }
                }
            }
            elsif ($token_type == LEFT_BRACKET) {
                my $lbnum = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    $token_data = $token->{data};

                    if ($token_type == LEFT_BRACKET) {
                        $lbnum++;
                    }
                    elsif ($token_type == RIGHT_BRACKET) {
                        last if --$lbnum <= 0;
                    }

                    # XXX ugly!!!
                    elsif ($token_type == DOUBLE) {
                        if ($allowed_types{Float} && $allowed_values{$token_data+0}) { # `+0` to convert to number
                            my $next_token = $tokens->[$i+1];
                            if ($next_token && $next_token->{type} == DOUBLE) {
                                push @invalid_tokens, $next_token;
                            }
                        }
                        else {
                            push @invalid_tokens, $token;
                        }
                    }
                    elsif ($token_type == INT) {
                        if (my ($base_type) = $token_data =~ /\A[0-9]([b0xe]).+\z/) { # XXX
                            if ($1 eq 'b') {
                                if (!$allowed_types{Binary}) {
                                    push @invalid_tokens, $token;
                                    goto JUDGEMENT;
                                }
                            }
                            elsif ($1 eq '0') {
                                if (!$allowed_types{Octal}) {
                                    push @invalid_tokens, $token;
                                    goto JUDGEMENT;
                                }
                            }
                            elsif ($1 eq 'x') {
                                if (!$allowed_types{Hex}) {
                                    push @invalid_tokens, $token;
                                    goto JUDGEMENT;
                                }
                            }
                            elsif ($1 eq 'e') {
                                if (!$allowed_types{Exp}) {
                                    push @invalid_tokens, $token;
                                    goto JUDGEMENT;
                                }
                            }
                        }

                        if (!$allowed_types{Int}) {
                            push @invalid_tokens, $token;
                        }
                        elsif (!$allowed_values{$token_data+0}) { # `+0` to convert to number
                            push @invalid_tokens, $token;
                        }
                    }
                }
            }
            JUDGEMENT:
            for my $t (@invalid_tokens) {
                push @violations, {
                    filename => $file,
                    line     => $t->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
        elsif ($token_type == FUNCTION) {
            $token = $tokens->[++$i];

            my $buf = [];
            my @statements = ();

            my $lbnum = 1;
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};

                if ($token_type == LEFT_BRACE) {
                    $lbnum++;
                }
                elsif ($token_type == RIGHT_BRACE) {
                    if (--$lbnum <= 0) {
                        last;
                    }
                }
                elsif ($token_type == SEMI_COLON) {
                    push @statements, $buf;
                    $buf = [];
                }
                else {
                    push @$buf, $token;
                }
            }

            if (scalar @statements > 1) {
                my $last_statement = pop @statements;

                my $return_value_token = pop @$last_statement or next;
                if ($return_value_token->{type} == RETURN) {
                    $return_value_token = pop @$last_statement or next;
                }

                if (
                    $return_value_token->{type} == INT ||
                    $return_value_token->{type} == DOUBLE
                ) {
                    # TODO it should support type constraint
                    if (!$allowed_values{$return_value_token->{data}+0}) { # `+0` to convert to number
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
        elsif ($token_type == FOR_STATEMENT || $token_type == FOREACH_STATEMENT) {
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};

                if ($token_type == SEMI_COLON || $token_type == LEFT_BRACE) { # XXX
                    last;
                }
                elsif ($token_type == SLICE) {
                    my $begin = $tokens->[$i-1] or last;
                    my $end   = $tokens->[$i+1] or last;
                    if ($begin->{type} == INT && $end->{type} == INT) {
                        if (
                            !$allowed_values{$begin->{data}} ||
                            !$allowed_values{$end->{data}}
                        ) {
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
        }
        elsif ($token_type == SEMI_COLON) {
            $is_in_constant_ctx = 0;
        }
    }

    return \@violations;
}

1;

