package Perl::Lint::Policy::ValuesAndExpressions::ProhibitMagicNumbers;
use strict;
use warnings;
no warnings qw/numeric/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Unnamed numeric literals make code less maintainable', # TODO
    EXPL => 'Unnamed numeric literals make code less maintainable',
};

my $file;
my $tokens;

my %allowed_values;
my %allowed_types;
my %constant_creator_subroutines;
my $allow_to_the_right_of_a_fat_comma;
my $is_readonly_array1_ctx;

sub evaluate {
    my $class = shift;
    $file     = shift;
    $tokens   = shift;
    my ($src, $args) = @_;

    %allowed_values = (
        0 => 1,
        1 => 1,
        2 => 1,
    );

    %allowed_types = (
        Int   => 1,
        Float => 1,
    );

    %constant_creator_subroutines = (
        plan     => 1,
        Readonly => 1,
        const    => 1,
    );

    $allow_to_the_right_of_a_fat_comma = 1;

    # initializing
    if (my $this_policies_arg = $args->{prohibit_magic_numbers}) {
        $allow_to_the_right_of_a_fat_comma =
            $this_policies_arg->{allow_to_the_right_of_a_fat_comma} // 1;

        my $allowed_values = $this_policies_arg->{allowed_values};
        if (defined $allowed_values) {
            delete $allowed_values{2}; # remove `2` from allowed list when allowed_values is specified

            for my $allowed_value (split /\s+/, $allowed_values) {
                my ($begin, $end) = split /[.][.]/, $allowed_value; # for range notation (e.g. `1..42`)
                if (defined $begin && defined $end) {
                    # used range notation
                    my ($delta) = $end =~ /:by [(] (.+) [)] \z/x; # for range notation with by (e.g. `-2.0..2.0:by(0.5)`)
                    $delta //= 1; # default delta

                    for (my $num = $begin; $num <= $end; $num += $delta) {
                        $allowed_values{$num} = 1;
                    }
                }
                else {
                    # not used range notation
                    $allowed_values{$allowed_value} = 1;
                }
            }
        }

        my $allowed_types = $this_policies_arg->{allowed_types};
        if (defined $allowed_types) {
            delete $allowed_types{Float}; # remove `Float` from allowed types list when allowed_types is specified

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
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $is_readonly_array1_ctx = 0;

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

                if ($token->{type} == NAMESPACE) {
                    if ($token_data eq 'Scalar' || $token_data eq 'Array') {
                        # when `Readonly::Scalar` or `Readonly::Array`,
                        # skip tokens to semi colon (means don't evaluate).
                        for ($i++; $token = $tokens->[$i]; $i++) {
                            $token_type = $token->{type};
                            if ($token_type == SEMI_COLON) {
                                last;
                            }
                        }
                        next;
                    }
                    elsif ($token_data eq 'Array1') {
                        # when `Readonly::Array1`
                        $i += 2; # skip to assigning token

                        $token = $tokens->[$i];
                        $token_type = $token->{type};
                        $token_data = $token->{data};

                        $is_readonly_array1_ctx = 1;

                        # no break!
                    }
                }
            }
        }

        # for the $VERSION variable
        if (
            $token_data eq '$VERSION' &&
            ($token_type == VAR || $token_type == GLOBAL_VAR)
        ) {
            # skip to end of line. Don't evaluate it.
            for ($i++; $token = $tokens->[$i]; $i++) {
                last if $token->{type} == SEMI_COLON;
            }
            next;
        }

        if (
            $token_type == ASSIGN ||
            ($token_type == ARROW && (!$allow_to_the_right_of_a_fat_comma || $is_readonly_array1_ctx))
        ) {
            push @violations, @{$class->_scan(\$i)};
            next;
        }

        if ($token_type == FUNCTION) {
            $token = $tokens->[++$i];

            my $statement  = [];
            my @statements = ();

            my $lbnum = 1;
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};

                if ($token_type == LEFT_BRACE) {
                    $lbnum++;
                }
                elsif ($token_type == RIGHT_BRACE) {
                    last if --$lbnum <= 0;
                }
                elsif ($token_type == SEMI_COLON) {
                    push @statements, $statement;
                    $statement = [];
                }
                else {
                    push @$statement, $token;
                }
            }

            if (scalar @statements > 1) { # when exists multiple statements in function
                my $last_statement = pop @statements;

                my $return_value_token = pop @$last_statement or next;
                if ($return_value_token->{type} == RETURN) {
                    $return_value_token = pop @$last_statement or next;
                }

                my $invalid_token;
                if ($return_value_token->{type} == INT) {
                    $invalid_token = $class->_validate_int_token($return_value_token);
                }
                elsif ($return_value_token->{type} == DOUBLE) {
                    $invalid_token = $class->_validate_doble_token($return_value_token);
                }

                if ($invalid_token) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }

            next;
        }

        if ($token_type == FOR_STATEMENT || $token_type == FOREACH_STATEMENT) {
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};

                if ($token_type == SEMI_COLON || $token_type == LEFT_BRACE) {
                    last;
                }
                elsif ($token_type == SLICE) { # e.g. for my $foo (1..42)
                    my $begin = $tokens->[$i-1] or last;
                    my $end   = $tokens->[$i+1] or last;
                    if ($begin->{type} == INT && $end->{type} == INT) {
                        if (!$allowed_values{$begin->{data}} || !$allowed_values{$end->{data}}) {
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
            next;
        }

        # for index of array
        if ($token_type == LEFT_BRACKET) {
            my $next_token = $tokens->[$i+1] or last;
            if ($next_token->{type} == INT) {
                my $int_token = $next_token;
                $next_token = $tokens->[$i+2] or last;

                my $invalid_token;
                if ($next_token->{type} == RIGHT_BRACKET) {
                    my $num = $int_token->{data} + 0;
                    if (!$allowed_values{$num} && $num ne -1) { # -1 is allowed specially when it is used as index of array
                        $invalid_token = $int_token;
                    }
                }
                elsif ($next_token->{type} != COMMA) { # if it is not enumeration (probably it is any handling for index of array)
                    $invalid_token = $next_token;
                }

                if ($invalid_token) {
                    push @violations, {
                        filename => $file,
                        line     => $invalid_token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }
            next;
        }
    }

    return \@violations;
}

my $is_in_assigning_context;
sub _scan {
    my ($class, $i) = @_;

    my $token = $tokens->[$$i] or return;
    my $token_type = $token->{type};
    my $token_data = $token->{data};

    if ($token_type == ASSIGN) {
        $is_in_assigning_context = 1;

        $token = $tokens->[++$$i] or return;
        $token_type = $token->{type};
        $token_data = $token->{data};
    }
    elsif ($token_type == ARROW) {
        $is_in_assigning_context = 0;
        if (!$allow_to_the_right_of_a_fat_comma || $is_readonly_array1_ctx) {
            $is_in_assigning_context = 1;
        }

        $token = $tokens->[++$$i] or return;
        $token_type = $token->{type};
        $token_data = $token->{data};
    }

    my $invalid_token;

    my @violations;
    if ($token_type == DOUBLE) {
        $invalid_token = $class->_validate_doble_token($token, $$i);
    }
    elsif ($token_type == INT) {
        $invalid_token = $class->_validate_int_token($token);
    }
    elsif ($token_type == LEFT_PAREN) {
        my $lpnum = 1;
        for ($$i++; $token = $tokens->[$$i]; $$i++) {
            $token_type = $token->{type};
            if ($token_type == LEFT_PAREN) {
                $lpnum++;
            }
            elsif ($token_type == RIGHT_PAREN) {
                last if --$lpnum <= 0;
            }
            else {
                push @violations, @{$class->_scan($i)};
            }
        }
    }
    elsif ($token_type == LEFT_BRACKET) {
        my $lbnum = 1;

        for ($$i++; $token = $tokens->[$$i]; $$i++) {
            $token_type = $token->{type};
            if ($token_type == LEFT_BRACKET) {
                $lbnum++;
            }
            elsif ($token_type == RIGHT_BRACKET) {
                last if --$lbnum <= 0;
            }
            else {
                push @violations, @{$class->_scan($i)};
            }
        }
    }

    if ($is_in_assigning_context && $invalid_token) {
        push @violations, {
            filename => $file,
            line     => $invalid_token->{line},
            description => DESC,
            explanation => EXPL,
            policy => __PACKAGE__,
        };
    }

    return \@violations;
}

sub _validate_int_token {
    my ($class, $token) = @_;

    my $token_data = $token->{data};

    if (my ($base_type) = $token_data =~ /\A[0-9]([b0xe]).+\z/) {
        if ($1 eq 'b') {
            return $token if !$allowed_types{Binary};
        }
        elsif ($1 eq '0') {
            return $token if !$allowed_types{Octal};
        }
        elsif ($1 eq 'x') {
            return $token if !$allowed_types{Hex};
        }
        elsif ($1 eq 'e') {
            return $token if !$allowed_types{Exp};
        }
    }

    if (!$allowed_types{Int}) {
        return $token;
    }

    if (!$allowed_values{all_integers} && !$allowed_values{$token_data+0}) { # `+0` to convert to number
        return $token;
    }

    return;
}

sub _validate_doble_token {
    my ($class, $token, $i) = @_;

    my $token_data = $token->{data};

    if ($i && $allowed_types{Float} && $allowed_values{$token_data+0}) { # `+0` to convert to number
        my $next_token = $tokens->[$i+1];
        if ($next_token && $next_token->{type} == DOUBLE) {
            return $next_token;
        }
    }
    elsif (!$allowed_values{all_integers} || $token_data !~ /[.]0+\z/) {
        return $token;
    }

    return;
}

1;

