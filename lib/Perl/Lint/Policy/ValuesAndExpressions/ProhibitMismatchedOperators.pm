package Perl::Lint::Policy::ValuesAndExpressions::ProhibitMismatchedOperators;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Mismatched operator',
    EXPL => 'Numeric/string operators and operands should match',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my %numeric_ops = (
        '==' => 1, '!=' => 1, '>'  => 1,
        '>=' => 1, '<'  => 1, '<=' => 1,
        '+'  => 1, '-'  => 1, '*'  => 1,
        '/'  => 1, '+=' => 1, '-=' => 1,
        '*=' => 1, '/=' => 1,
    );

    my %string_ops = (
        'eq' => 1, 'ne' => 1, 'lt' => 1,
        'gt' => 1, 'le' => 1, 'ge' => 1,
        '.'  => 1, '.=' => 1,
    );

    my %file_operators = (
        '-r' => 1, '-w' => 1, '-x' => 1,
        '-o' => 1, '-R' => 1, '-W' => 1,
        '-X' => 1, '-O' => 1, '-e' => 1,
        '-z' => 1, '-s' => 1, '-f' => 1,
        '-d' => 1, '-l' => 1, '-p' => 1,
        '-S' => 1, '-b' => 1, '-c' => 1,
        '-t' => 1, '-u' => 1, '-g' => 1,
        '-k' => 1, '-T' => 1, '-B' => 1,
        '-M' => 1, '-A' => 1,
    );

    my @violations;
    for (my $i = 0, my $token_type, my $token_data, my $token_kind; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_kind = $token->{kind};
        $token_data = $token->{data};

        if ($token_kind == KIND_OP || $token_kind == KIND_ASSIGN) {
            my $is_in_numeric_context = 0;
            my $is_in_string_context  = 0;
            if ($numeric_ops{$token_data}) {
                $is_in_numeric_context = 1;
            }
            elsif ($string_ops{$token_data}) {
                $is_in_string_context = 1;
            }

            if (!$is_in_numeric_context && !$is_in_string_context) {
                # Not target operator
                next;
            }

            my $before_token = $tokens->[$i-1];
            my $next_token   = $tokens->[$i+1];

            my $before_token_type = $before_token->{type};
            my $next_token_type   = $next_token->{type};

            my $is_before_token_variable = 0;
            if (
                # XXX enough?
                $before_token_type == VAR ||
                $before_token_type == ARRAY_VAR ||
                $before_token_type == HASH_VAR ||
                $before_token_type == GLOBAL_VAR ||
                $before_token_type == GLOBAL_ARRAY_VAR ||
                $before_token_type == GLOBAL_HASH_VAR
            ) {
                $is_before_token_variable = 1;
            }

            my $is_next_token_variable = 0;
            if (
                # XXX enough?
                $next_token_type == VAR ||
                $next_token_type == ARRAY_VAR ||
                $next_token_type == HASH_VAR ||
                $next_token_type == GLOBAL_VAR ||
                $next_token_type == GLOBAL_ARRAY_VAR ||
                $next_token_type == GLOBAL_HASH_VAR
            ) {
                $is_next_token_variable = 1;
            }

            if ($is_before_token_variable && $is_next_token_variable) {
                # when both of lvalue and rvalue are variable
                # e.g
                #     $foo > $bar
                $i++;
                next;
            }

            my $is_before_token_numeric = 0;
            if ($before_token_type == INT || $before_token_type == DOUBLE) {
                $is_before_token_numeric = 1;
                if ($tokens->[$i-2]->{type} == STRING_MUL) {
                    $is_before_token_numeric = 0;
                }
            }

            my $is_next_token_numeric = 0;
            if ($next_token_type == INT || $next_token_type == DOUBLE) {
                $is_next_token_numeric = 1;
            }

            if ($is_in_numeric_context) {
                if (
                    (!$is_before_token_numeric && !$is_before_token_variable) ||
                    (!$is_next_token_numeric && !$is_next_token_variable)
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
            elsif ($is_in_string_context) {
                if (
                    ($is_before_token_numeric && !$is_before_token_variable) ||
                    ($is_next_token_numeric && !$is_next_token_variable)
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
        elsif ($token_type == HANDLE) {
            if ($file_operators{$token_data}) {
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    $token_kind = $token->{kind};
                    if ($token_kind == KIND_OP) {
                        if ($string_ops{$token->{data}}) {
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
                    elsif ($token_type == SEMI_COLON) {
                        last; # fail safe
                    }
                }
            }
        }
    }

    return \@violations;
}

1;

