package Perl::Lint::Policy::Subroutines::RequireArgUnpacking;
use strict;
use warnings;
use List::Util qw/any/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Always unpack @_ first',
    EXPL => [178],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $require_arg_unpacking_arg = $args->{require_arg_unpacking};
    my $short_subroutine_statements = $require_arg_unpacking_arg->{short_subroutine_statements} || undef;
    my $allow_subscripts = $require_arg_unpacking_arg->{allow_subscripts} || 0;
    my @allow_delegation_to = split(/ /, $require_arg_unpacking_arg->{allow_delegation_to} || '');

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $next_token = $tokens->[$i+1];

        if (
            $token_type == FUNCTION_DECL ||
            ($token_type == KEY && $next_token->{type} == LEFT_BRACE)
        ) {
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};

                if ($token_type == LEFT_BRACE) {
                    my $begin_line = $token->{line};

                    # variable for each line
                    my $is_inherited = 0;
                    my $package_name = '';

                    my $is_violated = 0;
                    my $left_brace_num = 1;
                    for ($i++; $token = $tokens->[$i]; $i++) {
                        $token_type = $token->{type};
                        my $token_data = $token->{data};

                        if ($token_type == LEFT_BRACE) {
                            $left_brace_num++;
                        }
                        elsif ($token_type == RIGHT_BRACE) {
                            if (--$left_brace_num <= 0) {
                                my $end_line = $token->{line};
                                if ($is_violated) {
                                    if (
                                        not(defined $short_subroutine_statements) ||
                                        (($end_line - $begin_line - 1) > $short_subroutine_statements)
                                    ) {
                                        push @violations, {
                                            filename => $file,
                                            line     => $token->{line}, # TODO
                                            description => DESC,
                                            explanation => EXPL,
                                            policy => __PACKAGE__,
                                        };
                                    }
                                }
                                last;
                            }
                        }
                        elsif ($token_type == BUILTIN_FUNC && $token_data eq 'shift') {
                            $token = $tokens->[++$i];
                            $token_type = $token->{type};
                            if ($token_type == LEFT_PAREN) {
                                $token = $tokens->[++$i];
                                $token_type = $token->{type};
                            }
                            if ($token_type == ARGUMENT_ARRAY) {
                                $is_violated = 1;
                            }
                        }
                        elsif ($token_type == SPECIFIC_VALUE && $token_data eq '$_') {
                            $token = $tokens->[++$i];
                            $token_type = $token->{type};
                            if ($token_type == LEFT_BRACKET) {
                                $token = $tokens->[++$i];
                                $token_type = $token->{type};
                                if ($token_type == INT) {
                                    $is_violated = 1;
                                }
                            }
                        }
                        elsif ($token_type == ARGUMENT_ARRAY && !$allow_subscripts) {
                            $token = $tokens->[++$i];
                            $token_type = $token->{type};
                            if ($token_type == LEFT_BRACKET) {
                                $is_violated = 1;
                            }
                        }
                        elsif ($token_type == NAMESPACE || $token_type == METHOD) {
                            if ($is_inherited || $token_data eq 'NEXT' || $token_data eq 'SUPER') {
                                $is_inherited = 1;
                                $package_name .= $token_data;
                                next;
                            }

                            my $next_token = $tokens->[$i+1];
                            my $next_token_type = $next_token->{type};
                            if ($next_token_type == LEFT_PAREN) {
                                $next_token = $tokens->[$i+2];
                                $next_token_type = $next_token->{type};
                            }
                            if ($next_token_type == ARGUMENT_ARRAY) {
                                if (@allow_delegation_to && any {$_ eq $package_name || $_ eq $token_data} @allow_delegation_to) {
                                    next;
                                }
                                $is_violated = 1;
                            }
                            $package_name .= $token_data;
                        }
                        elsif ($token_type == NAMESPACE_RESOLVER) {
                            $package_name .= $token_data;
                        }
                        elsif ($token_type == SEMI_COLON) {
                            $is_inherited = 0;
                            $package_name = '';
                        }
                    }
                }
                elsif ($token_type == SEMI_COLON) {
                    last;
                }
            }
        }
    }

    return \@violations;
}

1;

